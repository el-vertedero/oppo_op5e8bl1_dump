#!/system/bin/sh
setenforce 0
remount
setprop vendor.debug.p2g.gsync.monitor.enable 0
setprop test.req.num 500
setprop vendor.debug.camera.halifut.log.level 1

echo 4 1 > /sys/module/mtk_vmm_notifier_mt6993/parameters/vmm_force_vol_ctrl
filename=$(date +"%Y%m%d%H%M")
setsid /vendor/bin/mt6993/test_hal --gtest_filter=TestHalIFPostProcVseMcnr.testNormalOutWithUseCase* > /sdcard/MCNR/test_hal${filename}.log 2>&1 &

sleep 1