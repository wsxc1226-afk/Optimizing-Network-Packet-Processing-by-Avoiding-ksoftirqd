# Optimizing ksoftirqd Avoidance for Network Packet Processing

## 🚀 Overview

This project implements kernel-level optimizations to minimize the involvement of the `ksoftirqd` thread in Linux network packet processing. By reducing unnecessary `ksoftirqd` wake-ups, we improve CPU efficiency, lower latency, and increase network throughput in high-performance scenarios.

Through direct analysis of Linux kernel source code, including NIC interrupts, GRO, SoftIRQ scheduling, DMA, backlog processing, `sk_buff` handling, RFS, and RPS, we explored opportunities to optimize packet reception.

---

## 🛠 Background

In Linux, network packet processing relies on **SoftIRQs**. NIC interrupts trigger softirqs, but if processing exceeds a time or execution limit, the kernel thread `ksoftirqd` takes over. While this ensures system stability, it also adds CPU overhead and increases latency under sustained traffic.

This project focuses on:

* Reducing unnecessary `ksoftirqd` activations
* Optimizing SoftIRQ execution for network packet reception
* Maintaining system stability while improving throughput

---

## 🎯 Goals

* Minimize `ksoftirqd` activations during continuous network traffic
* Reduce CPU overhead caused by SoftIRQ handling
* Maintain safe and stable kernel operation
* Demonstrate measurable throughput improvement through controlled experiments

---

## 🛠 Implementation

### Kernel Function Analysis

* Traced the **`__do_softirq`** function to understand SoftIRQ execution flow
* Analyzed **`net_rx_action`** to identify overhead points caused by repeated SoftIRQ handling

### Key Modifications

1. **Unlimited SoftIRQ Execution Until Queue Empty**

   * Original limits on SoftIRQ execution count and duration were removed
   * Pending SoftIRQs now execute until the queue is empty
   * Stability maintained by dynamically pinning CPUs to network receive tasks

2. **Reduced `net_rx_action` Invocation Overhead**

   * Increased internal polling iterations within `net_rx_action`
   * Reduced the number of function calls, lowering SoftIRQ handling overhead and unnecessary `ksoftirqd` wake-ups

### Safety Considerations

* Dynamic CPU core allocation prevents SoftIRQ execution from starving other processes
* Verified system stability under sustained network traffic

---

## ⚙ Experimental Setup

* **OS**: Ubuntu 22.04
* **Kernel**: Linux 5.15.90
* **Network**: 1 Gbps Point-to-Point LAN
* **Benchmark Tool**: `iperf3`
* **Methodology**: 10 iterations per test, comparing original and modified kernel performance

---

## 📊 Results

| Metric                    | Original Kernel | Modified Kernel       |
| ------------------------- | --------------- | --------------------- |
| `ksoftirqd` Activity      | Active          | Significantly Reduced |
| Network Throughput Change | Baseline        | +0.5% \~ +2%          |

* Continuous packet reception showed measurable throughput improvement
* CPU overhead due to `ksoftirqd` was effectively reduced

---

## ✅ Conclusions

* Modifications successfully minimized `ksoftirqd` activations
* Network receive path efficiency improved, resulting in measurable throughput gains
* CPU resources were better utilized without compromising system stability

This demonstrates that targeted kernel-level optimizations can significantly enhance network performance under high-load conditions.

---

