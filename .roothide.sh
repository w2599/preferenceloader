#!/bin/bash
export LC_ALL=C
export THEOS=/Users/zqbb/theos_roothide
export ARCHS=arm64e

#取绝对路径
tweakPath=$(cd "$(dirname "$0")";pwd)
buildPath="$(dirname "$tweakPath")/__build_roothide/$(basename "$tweakPath")"
echo "tweakPath: $tweakPath"
echo "buildPath: $buildPath"
cd $tweakPath
# make clean


versionFile=$(ls _version_* | head -n 1)
versionSee=$(echo $versionFile | sed 's/_version_//g')


# 备份原文件
rm -rf $buildPath && mkdir -p $buildPath && cp -a ./ $buildPath && cd $buildPath

# 需要查找替换的文本列表
text_to_replace=(
)


# 生成随机字符串，并将其保存到数组中
random_strings=()
for ((i=0; i<${#text_to_replace[@]}; i++)); do
    while true; do
        # 生成20位的随机字符串，以大写字母开头
        random_string=$(LC_ALL=C tr -dc 'A-Z' < /dev/urandom | head -c 5)
        
        # 检查是否已经存在
        if [[ ! " ${random_strings[@]} " =~ " ${random_string} " ]]; then
            # 如果不存在则保存到数组中
            random_strings[$i]=$random_string
            break
        fi
    done
done


# 遍历替换
for ((i=0; i<${#text_to_replace[@]}; i++)); do
    # 替换文件中的文本
    find . -type f -exec sed -i '' "s/${text_to_replace[$i]}/${random_strings[$i]}/g" {} +
done
echo "替换完成"


##替换版本号
sed -i '' "s/^\(Version:\s*\).*/\1 ${versionSee}/" control
echo "编译版本号为${versionSee}"


if [ $1 -eq "0" ]
then
    export THEOS_DEVICE_IP=192.168.31.158
    export THEOS_DEVICE_PORT=54322
    export package FINALPACKAGE=1
	export THEOS_PACKAGE_SCHEME=rootless

	make do -j$(sysctl -n hw.physicalcpu)
	exit
fi

if [ $1 -eq "10" ]
then
    export package FINALPACKAGE=1
	export THEOS_PACKAGE_SCHEME=roothide

	make do -j$(sysctl -n hw.physicalcpu)
	cp -f ./packages/*.deb /Users/zqbb/Documents/GitHub/roothide/
	exit
fi


if [ $1 -eq "1" ]
then
    export package FINALPACKAGE=1
	export THEOS_PACKAGE_SCHEME=roothide
	make do 
	exit
fi

if [ $1 -eq "2" ]
then
	export package FINALPACKAGE=1
    # export DEVELOPER_DIR="/Applications/Xcode-14.3.0.app/Contents/Developer"

	export THEOS_PACKAGE_SCHEME=roothide
    make package -j$(sysctl -n hw.physicalcpu)

    unset THEOS_PACKAGE_SCHEME
    make clean
    export THEOS_PACKAGE_SCHEME=rootless
    make package -j$(sysctl -n hw.physicalcpu)

	# cp -f ./packages/*.deb $tweakPath
	mv ./packages/*.deb ~/Documents/GitHub/myTweaks/rootless/
    exit
fi