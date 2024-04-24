插件集成步骤:
1.pubspec.yaml中添加以下依赖:
```
flutter_printer:
    git:
      url: https://github.com/shijia2118/flutter_printer.git
```

2.在项目的根目录的Android > app > main > 下新建jniLibs目录，同时添加相关.so库(见插件demo)