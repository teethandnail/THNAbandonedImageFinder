## 背景
维护久了的工程中会有很多不再使用的图片

## 功能
找出废弃的图片资源，减小app包大小

## 说明
* 用[UIImage imageNamed:]初始化图片的工程可以直接使用THNAbandonedImageFinder.h里提供的方法
* 若是模块化开发或用自定义的UIImage初始化方法的工程，则可参考THNAbandonedImageFinder+MyProject.h里的实现，做少许修改也能很方便的实现


