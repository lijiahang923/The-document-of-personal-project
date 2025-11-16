# 给脚本执行权限
chmod +x check_python_pytorch.sh

# 运行脚本
./check_python_pytorch.sh

# 或者在虚拟环境中运行
source your_venv/bin/activate
./check_python_pytorch.sh

#ATTENTION!!!!!!
#如果在主环境没有检测到pytorch，那就需要先按照README提示的虚拟运行环境，对环境进行激活再运行检测脚本，才能得到理想的结果
