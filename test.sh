#!/bin/bash

# 기존 포트(5201)에서 동작 중인 프로세스 종료
sudo kill $(sudo lsof -t -i :5201)

# 모듈 파라미터 값 초기화
echo "Initializing module parameters..."
echo 1 > /sys/module/softirq/parameters/modified
echo 0 > /sys/module/softirq/parameters/count_local_bh_enable_ip
echo 0 > /sys/module/softirq/parameters/count_invoke_softirq
echo 0 > /sys/module/softirq/parameters/count_run_ksoftirqd
echo 0 > /sys/module/softirq/parameters/count_l
echo 0 > /sys/module/softirq/parameters/count_i
echo 0 > /sys/module/softirq/parameters/count_r
echo 0 > /sys/module/dev/parameters/count_rx_action

# IRQ affinity 설정 (19번 CPU 활성화)
affinity="80000"  # 16진수 값

# IRQ 번호 31, 32, 33, 34에 대해 설정
for irq in 31 32 33 34; do
    echo $affinity > /proc/irq/$irq/smp_affinity
    echo "IRQ $irq is now handled by CPU 19."
done

# iptables 설정 - TCP 허용
iptables -A INPUT -p tcp -j ACCEPT
iptables -A OUTPUT -p tcp -j ACCEPT

# CPU 18, 19에 대해 stress-ng 5분 10초 동안 실행
echo "Running stress-ng on CPU 18 and 19 for 5 minutes and 10 seconds..."
taskset -c 18 stress-ng --cpu 1 --timeout 910s &
taskset -c 19 stress-ng --cpu 1 --timeout 910s &

# iperf3 서버 실행 (CPU 18 고정, 백그라운드)
echo "Starting iperf3 server..."
taskset -c 18 iperf3 -s &

# 5분 10초 대기
sleep 910

# 모듈 파라미터 값 출력
echo "Module parameters values after 5 minutes and 20 seconds:"
echo "count_run_l: $(cat /sys/module/softirq/parameters/count_l)"
echo "count_run_i: $(cat /sys/module/softirq/parameters/count_i)"
echo "count_run_r: $(cat /sys/module/softirq/parameters/count_r)"
echo "count_local_bh_enable_ip: $(cat /sys/module/softirq/parameters/count_local_bh_enable_ip)"
echo "count_invoke_softirq: $(cat /sys/module/softirq/parameters/count_invoke_softirq)"
echo "count_run_ksoftirqd: $(cat /sys/module/softirq/parameters/count_run_ksoftirqd)"
echo "count_count_rx_action: $(cat /sys/module/dev/parameters/count_rx_action)"

# 종료 메시지
echo "Script execution completed."
