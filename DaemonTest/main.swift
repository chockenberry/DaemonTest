//
//  main.swift
//  DaemonTest
//
//  Created by Craig Hockenberry on 3/23/24.
//

import Foundation

let controller = Controller()
controller.start()
RunLoop.current.run()

class Controller {
	
	var timer: Timer?
	
	init() {
	}

	func start() {
		guard timer == nil else { return }

		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
			autoreleasepool {
				self.leakKernelMemory()
			}
		}
	}
	
	func stop() {
		guard let timer else { return }
		
		timer.invalidate()
		self.timer = nil
	}

	// NOTE: This functions leaks kernel memory. You won't see any warnings from static analysis, and Leaks in Instruments shows
	// no issues and a constant amount of process memory.
	//
	// You only know there's a problem when you track the physical memory footprint (which takes kernel memory into account). Run
	// these commands in a shell while this daemon is running and you'll see a constantly increasing amount memory being used:
	//
	//   while true; do leaks DaemonTest | grep "footprint"; sleep 5; done
	
	func leakKernelMemory() {
		print("leak kernel memory...")
	
		var processorCount: natural_t = 0
		var processorInfoArray: processor_info_array_t? = nil
		var processorInfoCount: mach_msg_type_number_t = 0
		let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, &processorInfoArray, &processorInfoCount)
		guard result == KERN_SUCCESS else { return }
		guard let processorInfoArray else { return }

		// NOTE: The following line of code compiles cleanly, doesn't return an error, and continuously leaks memory.
		let dealloc_result = vm_deallocate(mach_task_self_, vm_address_t(processorInfoArray.pointee), vm_size_t(processorInfoCount))
		if dealloc_result != KERN_SUCCESS {
			print("vm_deallocate failed with: \(dealloc_result)")
		}
		// The fix is to use bitPattern: https://stackoverflow.com/a/48630296/132867
		//vm_deallocate(mach_task_self_, vm_address_t(bitPattern: processorInfoArray), vm_size_t(processorInfoCount))
		// This took a long time to track down. And even longer to figure out.
	}

}

