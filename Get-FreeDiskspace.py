import ctypes
import os
import platform
import sys

def get_free_space_gb(dirname):
    """Return Windows specific folder/drive free space (in GB)."""
    free_bytes = ctypes.c_ulonglong(0)
    ctypes.windll.kernel32.GetDiskFreeSpaceExW(ctypes.c_wchar_p(dirname), None, None, ctypes.pointer(free_bytes))
    return free_bytes.value / 1024 / 1024 / 1024 

if  get_free_space_gb("f:") > 50 :
    print ("Drive free space is OK")
    quit(0)
else:
    print ("Drive free space is KO")
    quit(1)


