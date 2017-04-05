LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := stdin2gz
LOCAL_MODULE_TAGS := optional debug
LOCAL_SRC_FILES := stdin2gz.c
include $(BUILD_EXECUTABLE)
