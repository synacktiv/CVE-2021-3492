#! /bin/bash

FTRACE_DIR="/sys/kernel/debug/tracing/"
MAX_SYSCALLS=500

# Configure ftrace
echo function > ${FTRACE_DIR}/current_tracer
echo "__x64_sys_*" > ${FTRACE_DIR}/set_ftrace_filter
echo "__ia32_sys_*" >> ${FTRACE_DIR}/set_ftrace_filter

#rm -f result.txt

# For each syscalls
for i in $(seq $MAX_SYSCALLS)
do
	if [ $i -lt 500 ]; then
		continue
	fi
	# Make sure trace is disabled
	echo "0" > ${FTRACE_DIR}/tracing_on
	echo "" > ${FTRACE_DIR}/trace
	echo "Running for syscall $i"
	rm -rf syscall_$i
	mkdir syscall_$i
	cd syscall_$i
	timeout 5 python3 ../syscalls.py $i > log
	exit_code="${?}"
	echo "0" > ${FTRACE_DIR}/tracing_on
	handler_kernel="unknown"
	if [ ${exit_code} -eq 0 ]; then
		cat ${FTRACE_DIR}/trace > trace
		pid=$(grep "PID" log | sed s/"PID "//)
		handler_kernel=$(grep "__x64_sys_" trace | grep $pid | tail --lines="+2" | head -1 | awk '{ print $5; }')
	fi
	cd -
	echo "Syscall $i : $handler_kernel" >> result.txt
done

# Make sure trace is disabled
echo "0" > ${FTRACE_DIR}/tracing_on
echo "" > ${FTRACE_DIR}/trace
