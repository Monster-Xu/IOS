# 音频播放控件 (AudioPlayerView) 使用说明

## 概述

`AudioPlayerView` 是一个现代化的音频播放控件，专为故事播放场景设计。它具有漂亮的毛玻璃效果、波形动画、进度控制等功能。

## 主要特性

### 🎵 音频播放功能
- 支持本地和网络音频文件播放
- 自动下载网络音频文件到本地缓存
- 播放/暂停控制
- 进度条拖拽控制
- 实时时间显示

### 🎨 视觉设计
- 毛玻璃背景效果
- 动态波形动画可视化
- 现代化的UI设计
- 平滑的动画过渡效果
- 支持浅色/深色模式

### 📱 用户交互
- 点击背景区域关闭播放器
- 进度条拖拽控制播放位置
- 播放状态实时反馈
- 响应式布局适配

## 集成方式

### 1. 在故事列表中的集成

当 `storyStatus == 5` 时，播放按钮变为可用状态：

```objective-c
// 在 CreationViewController.m 中
- (void)playStoryAtIndex:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    if (model.storyStatus == 5) {
        // 创建和显示音频播放器
        self.currentAudioPlayer = [[AudioPlayerView alloc] 
            initWithAudioURL:model.audioUrl 
                  storyTitle:model.storyName];
        self.currentAudioPlayer.delegate = self;
        
        [self.currentAudioPlayer showInView:self.view];
        [self.currentAudioPlayer play];
    }
}
```

### 2. 代理方法实现

```objective-c
#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    // 播放开始
}

- (void)audioPlayerDidPause {
    // 播放暂停
}

- (void)audioPlayerDidFinish {
    // 播放完成
}

- (void)audioPlayerDidClose {
    // 播放器关闭
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress 
                         currentTime:(NSTimeInterval)currentTime 
                           totalTime:(NSTimeInterval)totalTime {
    // 播放进度更新
}
```

## 状态控制逻辑

根据 `storyStatus` 控制不同的按钮行为：

| storyStatus | 编辑按钮 | 播放按钮 | 点击行为 |
|-------------|----------|----------|----------|
| 1 (生成中) | 隐藏 | 禁用 | 无 |
| 2 (待配音) | 显示 | 禁用 | 跳转到配音页面 |
| 3 (失败) | 显示 | 禁用 | 重新编辑 |
| **5 (完成)** | 显示 | **可用** | **弹出播放器** |
| 6 (其他) | 显示 | 禁用 | 跳转到配音页面 |

## 使用示例

### 基本用法

```objective-c
// 创建播放器
AudioPlayerView *player = [[AudioPlayerView alloc] 
    initWithAudioURL:@"https://example.com/audio.mp3" 
          storyTitle:@"小红帽的故事"];

// 设置代理
player.delegate = self;

// 显示并播放
[player showInView:self.view];
[player play];
```

### 手动控制

```objective-c
// 播放
[player play];

// 暂停
[player pause];

// 停止
[player stop];

// 检查播放状态
BOOL isPlaying = [player isPlaying];

// 隐藏播放器
[player hide];
```

## 技术实现

### 音频处理
- 使用 `AVAudioPlayer` 进行音频播放
- 支持 AVAudioSession 管理
- 自动处理音频会话冲突

### 网络音频
- 使用 NSURLSession 下载网络音频
- 缓存到本地临时目录
- 支持各种音频格式（MP3、WAV等）

### 动画效果
- CADisplayLink 驱动的波形动画
- 基于音频播放状态的实时动画
- 平滑的显示/隐藏过渡动画

### 内存管理
- 自动清理临时音频文件
- 正确的代理模式实现
- 及时释放音频资源

## 注意事项

1. **音频格式支持**：支持 iOS 系统支持的所有音频格式
2. **网络权限**：需要在 Info.plist 中配置网络访问权限
3. **音频权限**：会自动处理音频播放权限
4. **内存使用**：大音频文件会占用较多内存，建议控制文件大小
5. **后台播放**：当前未配置后台播放，应用进入后台时会暂停

## 自定义配置

可以通过修改 `AudioPlayerView.m` 中的常量来自定义外观：

```objective-c
// 波形条数量
NSInteger waveformBars = 40;

// 波形条宽度和间距
CGFloat barWidth = 2.0;
CGFloat spacing = 1.5;

// 播放器尺寸
make.height.mas_equalTo(220);
```

## 故障排除

### 常见问题

1. **音频无法播放**
   - 检查 audioUrl 是否有效
   - 确认网络连接正常
   - 查看控制台音频错误日志

2. **播放器显示异常**
   - 确认父视图布局正确
   - 检查是否重复创建播放器实例

3. **进度条不更新**
   - 确认音频文件有效
   - 检查 Timer 是否正常运行

### 调试建议

- 开启详细日志输出
- 使用 Xcode 音频调试工具
- 测试不同格式的音频文件