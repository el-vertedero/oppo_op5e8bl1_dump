#!/system/bin/sh

# Create directory and initialize result file
rm -rf /sdcard/ISP_SLT_TEST
mkdir -p /sdcard/ISP_SLT_TEST
# echo "ISP SLT2 TEST START" > /sdcard/ISP_SLT_TEST/result.json

# Kill camera processes
stop camerahalserver

# Run camera test
/vendor/bin/camsys_v4l2_ut STAGGER --sensor 0 8 --exp 2 2 --exp_order 1 --stagger_type 1 --dc --round 5 --raw 7 > /dev/null &

# Set properties and run ISP test
setprop vendor.camera.imgsys.sltmode 1
setprop persist.vendor.mtk.camera.out.bytealign 0
/vendor/bin/ISP_MSSV_TEST --gtest_filter=IspMssvTest.IspSLT2 > /dev/null &

# Check if processes are running
# sleep 1 # give processes time to start

# Check for camsys_v4l2_ut process
if ! ps -A | grep camsys_v4l2_ut | grep -q -v grep; then
p1_fail_output=$(cat <<EOF
[{
  "isp_p1" : "fail",
EOF
)
    echo "$p1_fail_output" >> /sdcard/ISP_SLT_TEST/result.json
else
p1_pass_output=$(cat <<EOF
[{
  "isp_p1" : "pass",
EOF
)
    echo "$p1_pass_output" >> /sdcard/ISP_SLT_TEST/result.json
fi

# Check for ISP_MSSV_TEST process
if ! ps -A | grep ISP_MSSV_TEST | grep -q -v grep; then
p2_fail_output=$(cat <<EOF
  "isp_p2" : "fail"
}]
EOF
)
    echo "$p2_fail_output" >> /sdcard/ISP_SLT_TEST/result.json
else
p2_pass_output=$(cat <<EOF
  "isp_p2" : "pass"
}]
EOF
)
    echo "$p2_pass_output" >> /sdcard/ISP_SLT_TEST/result.json
fi

# Clean up processes
kill -9 $(ps -A | grep -E '[c]amsys_v4l2_ut' | awk '{print $2}')
kill -9 $(ps -A | grep -E '[I]SP_MSSV_TEST' | awk '{print $2}')

setprop vendor.camera.imgsys.sltmode 0
start camerahalserver

exit 0