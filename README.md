# Optimizing ksoftirqd Avoidance for Network Packet Processing

## Overview

This project proposes and implements a kernel-level optimization method to reduce the involvement of `ksoftirqd` in network packet processing within the Linux kernel. By minimizing `ksoftirqd` intervention, we aim to enhance performance by reducing CPU overhead and improving packet throughput.

## Background

In Linux, network packet processing relies on the `SoftIRQ` mechanism. When packet handling cannot be completed within a short time, the kernel thread `ksoftirqd` is triggered to take over the remaining tasks. However, this often leads to CPU contention and increased latency.

This project introduces a technique to prevent unnecessary wake-ups of `ksoftirqd`, thereby optimizing CPU usage and improving network performance.

## Goals

- Reduce the frequency of `ksoftirqd` activation
- Improve throughput and lower network latency
- Evaluate the effectiveness of the approach through controlled experiments

## Implementation

- Analyzed the call path of the `__do_softirq` function in the Linux kernel
- Modified `__do_softirq` to introduce additional conditional checks that reduce the chance of `ksoftirqd` being woken up
- Maintained functional compatibility with standard packet handling

## Experimental Setup

- **OS**: Ubuntu 22.04
- **Kernel**: Linux 5.15.90
- **Network**: 1Gbps P2P LAN
- **Tool**: `iperf3`

Experiments compared the original and modified kernels over 10 iterations to measure throughput differences.

## Results

| Metric               | Original `__do_softirq` | Modified `__do_softirq` |
|----------------------|--------------------------|---------------------------|
| ksoftirqd Activity   | Active                   | Avoided                   |
| Throughput Change    | Baseline                 | +0.5% to +2% improvement  |

## Conclusions

The proposed changes to `__do_softirq` successfully minimized `ksoftirqd` activation, resulting in measurable throughput gains. This demonstrates the potential for kernel-level tuning to significantly improve network performance under certain conditions.

## Future Work

- **Dynamic Core Allocation**: Adjust IRQ core assignments based on real-time traffic load
- **Traffic-Aware Scheduling**: Dynamically control `__do_softirq` conditions depending on packet flow
- **net_rx_action Optimization**: Extend similar logic to `net_rx_action`, with attention to side effects involving other SoftIRQs

