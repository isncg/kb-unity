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
| deltaTime |	The interval between this frame and the preceding frame. The interval is unscaled and expressed in seconds. |
| effectiveParentSpeed | The accumulated speed of the parent Playable during the PlayableGraph traversal. |
| effectivePlayState | The accumulated play state of this playable. |
| effectiveSpeed | The accumulated speed of the Playable during the PlayableGraph traversal. |
| effectiveWeight |	The accumulated weight of the Playable during the PlayableGraph traversal. |
| evaluationType | Indicates the type of evaluation that caused PlayableGraph.PrepareFrame to be called. |
| frameId | The current frame identifier. |
| output | The PlayableOutput that initiated this graph traversal. |
| seekOccurred | Indicates that the local time was explicitly set. |
| timeHeld | Indicates the local time did not advance because it has reached the duration and the extrapolation mode is set to Hold. |
| timeLooped | Indicates the local time wrapped because it has reached the duration and the extrapolation mode is set to Loop. |
| weight | The weight of the current Playable. |

### effectivePlayState
playable 及其祖先的累积的播放状态。playable 和它所有祖先中的任一一个设置为 Paused，则有效状态为 Paused

### evaluationType
**Evaluate:** 函数调用了 PlayableGraph.Evaluate 导致的求值
**Playaback:** 运行时正常播放时调用的，需要由 PlayableGraph.Play 开始播放

## PlayableBehaviour 回调
https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Playables.PlayableBehaviour.html

| 回调方法 | 调用时机 |
|---|---|
| OnBehaviourPause | 	This method is invoked when one of the following situations occurs: The effective play state during traversal is changed to PlayState.Paused. This state is indicated by FrameData.effectivePlayState. The PlayableGraph is stopped while the playable play state is Playing. This state is indicated by PlayableGraph.IsPlaying returning true. |
| OnBehaviourPlay | 	This function is called when the Playable play state is changed to PlayState.Playing. |
| OnGraphStart | 	This function is called when the PlayableGraph that owns this PlayableBehaviour starts. |
| OnGraphStop | 	This function is called when the PlayableGraph that owns this PlayableBehaviour stops. |
| OnPlayableCreate | 	This function is called when the Playable that owns the PlayableBehaviour is created. |
| OnPlayableDestroy | 	This function is called when the Playable that owns the PlayableBehaviour is destroyed. |
| PrepareData | 	This function is called during the PrepareData phase of the PlayableGraph. |
| PrepareFrame | 	This function is called during the PrepareFrame phase of the PlayableGraph. |
| ProcessFrame | 	This function is called during the ProcessFrame phase of the PlayableGraph. |

### PlayableGraph 播放过程中回调的执行顺序
1. OnGraphStart 调用 PlayableGraph.Play() 方法后，或首次手动调用 PlayableGraph.Evaluate() 时
2. OnBehaviourPlay
3. OnBehaviourPause
4. OnGraphStop
