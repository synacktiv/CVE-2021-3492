import os, ctypes, sys

def write_file(file, data, mode='w'):
	f = open(file, mode)
	f.write(data)
	f.close()

raw_syscall = ctypes.CDLL(None).syscall
raw_syscall.restype = ctypes.c_long
raw_syscall.argtypes = ctypes.c_long, ctypes.c_long, ctypes.c_long, ctypes.c_long

print('PID %d' % os.getpid())

# Enabling trace capture
ftrace_dir = '/sys/kernel/debug/tracing/'
#write_file(ftrace_dir + 'tracing_on', '1\n')

# Make syscall
sysno = int(sys.argv[1])
ret = raw_syscall(sysno, 0, 0, 0, 0)

# Disable trace capture
#write_file(ftrace_dir + 'tracing_on', '0\n')

# Print ret
print('Syscall %d ret %s' % (sysno, repr(ret)))

