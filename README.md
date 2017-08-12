## 背景
长久维护的工程中会有很多不再使用的图片

## 功能
找出废弃的图片资源，减小app包大小

## 说明
* 用系统的图片初始化方法[UIImage imageNamed:]的工程可以直接使用THNAbandonedImageFinder.h里提供的方法
* 若是模块化开发的工程和使用自定义的UIImage初始化方法的工程，则需参考THNAbandonedImageFinder+MyProject.h里的实现，做点修改也能很方便的实现
