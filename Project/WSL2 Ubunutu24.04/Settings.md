python 3.12 default
pytorch gpu130
anaconda installed
ROS2 Jazzy（setted terminal start same time）
$echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
Gazebo Harmonic
$# 修复 Gazebo/Rviz 在 WSL2 上的渲染崩溃问题
echo "export QT_QPA_PLATFORM=xcb" >> ~/.bashrc
source ~/.bashrc
