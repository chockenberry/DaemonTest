# DaemonTest
 Leak kernel memory for fun and profit!

If you've ever wanted to see Swift code that shows no problems during static analysis, or any leaks while running with Instruments, yet still leaks memory at a rate of 1 MB per minute, you've come to the right place.

Check out the `leakKernelMemory()` function in `main.swift`.

The key to understanding what's going on is to watch the process using `leaks` and ignore the part about leaks 😀. Focus on the process footprint instead. To see where the memory is going, use `footprint`. Both of these tools have `man` pages.

