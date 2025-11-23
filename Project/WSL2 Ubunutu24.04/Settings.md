python 3.12 default

pytorch gpu130

anaconda installed

ROS2 Jazzy（setted terminal start same time）
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc

Gazebo Harmonic  
# 修复 Gazebo/Rviz 在 WSL2 上的渲染崩溃问题
echo "export QT_QPA_PLATFORM=xcb" >> ~/.bashrc
source ~/.bashrc

虚拟环境
我们在用户目录下创建一个名为 ros_ai_env 的环境。
注意：这里加 --system-site-packages 是关键，这让你的虚拟环境既能安装新包，又能读取到安装在系统里的 rclpy (ROS 2 的 Python 库)。
python3 -m venv --system-site-packages ~/ros_ai_env
激活环境
source ~/ros_ai_env/bin/activate
每次打开新终端，如果你要跑深度学习代码，先输入 source ~/ros_ai_env/bin/activate。
如果你只是跑普通的 ROS 2 命令（不涉及你自己装的 AI 库），不激活也可以。
为了方便，你可以给这个激活命令起个别名。在 ~/.bashrc 最后加入：
alias ai="source ~/ros_ai_env/bin/activate"
以后输入 ai 就能进入环境。

为了环境的稳健性，降级 NumPy 到 1.26.4 是目前最安全的选择。
