# PlayableBehaviour
- 所有 playable 脚本的基类
- 为 PlayableGraph 添加用户定义行为
- 连接 PlayableGraph 的出口后才生效

## Playable.PlayState 枚举
- **Paused:** Playable 已被暂停，local time 将不会步进增长
- **Playing:** Playable 正在播放

## FrameData 结构
https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Playables.FrameData.html

Playable 通过 Playable.PrepareFrame 接收到的帧信息

| 属性 | 描述 |
|------|------|
| deltaTime |	当前帧与前一帧的间隔时间，无缩放，单位为秒 |
| effectiveParentSpeed | 祖先的累积速度（乘法叠加？） |
| effectivePlayState | 自身及其祖先的累积的播放状态 |
| effectiveSpeed | 累积速度 |
| effectiveWeight |	累积权重 |
| evaluationType | PlayableGraph.PrepareFrame 的调用来源类型，Evaluate 或 Playaback |
| frameId | 当前帧的标时id |
| output | 从哪个 PlayableOutput 遍历而来的 |
| seekOccurred | 显式设置过 local time |
| timeHeld | 表明 local time 由于到达了持续时长且extrapolation mode 为 Hold 所以没有增长 |
| timeLooped | 标时 local time 由于到达了持续时长且extrapolation mode 为 Loop 所以从头开始计了时 |
| weight | Playable 当前的权重 |

### effectiveParentSpeed
？The accumulated speed of the parent Playable during the PlayableGraph traversal.

### effectivePlayState
playable 自身及其祖先的累积的播放状态。playable 和它所有祖先中的任一一个设置为 Paused，则有效状态为 Paused

### evaluationType
**Evaluate:** 函数调用了 PlayableGraph.Evaluate 导致的求值
**Playaback:** 运行时正常播放时调用的，需要由 PlayableGraph.Play 开始播放

### Playable delay (Obsolete)
已过时，不要考虑它了

### Playable local time
Playable 从播放开始到当前帧的时间，可以通过 PlayableExtensions.GetTime 获得。对于动画来说，它是动画 Clip 的播放时间

### Playable lead time
？不清楚用途，可能是预计算 lead time + local time 时的数据？


## PlayableBehaviour 回调
https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Playables.PlayableBehaviour.html

| 回调方法 | 调用时机 |
|---|---|
| OnBehaviourPause | 1：Playable 的累积的播放状态变为 Paused, 2:Playable的播放状态为 Playing 而 PlayableGraph 的 IsPlaying 变为 false |
| OnBehaviourPlay | Playable （自身？）的播放状态变为 PlayState.Playing |
| OnGraphStart | 持有该 PlayableBehaviour 的 PlayableGraph 开始播放 |
| OnGraphStop | 持有该 PlayableBehaviour 的 PlayableGraph 停止播放 |
| OnPlayableCreate | 	持有该 PlayableBehaviour 的 Playable 被创建 |
| OnPlayableDestroy | 持有该 PlayableBehaviour 的 Playable 被销毁 |
| PrepareData | 	PlayableGraph 的 PrepareData 阶段 |
| PrepareFrame | 	PlayableGraph 的 PrepareFrame 阶段 |
| ProcessFrame | 	PlayableGraph 的 ProcessFrame 阶段 |

### PlayableGraph 播放过程中回调的执行顺序
1. OnGraphStart 调用 PlayableGraph.Play() 方法后，或首次手动调用 PlayableGraph.Evaluate() 时
2. OnBehaviourPlay 与 OnGraphStart 在同一帧
3. OnBehaviourPause 播放至结尾
4. OnGraphStop 所有 OnBehaviourPause 之后
