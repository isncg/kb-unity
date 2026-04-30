# SRP

https://catlikecoding.com/unity/tutorials/custom-srp/

https://zhuanlan.zhihu.com/p/353687806

https://github.com/Unity-Technologies/UniversalRenderingExamples

## 类

- RenderPipelineAsset RenderPipeline 的工厂类，用于序列化 RenderPipeline，供编辑器设置
- RenderPipeline 渲染管线执行类，通过 Render 函数执行一帧渲染
- ScriptableRenderContext 渲染 API 封装类，用于提交渲染状态和绘制命令

### 示例：自定义管线

```csharp
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset {
    protected override RenderPipeline CreatePipeline () {
        return new CustomRenderPipeline();
    }
}
```

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline {
    protected override void Render ( ScriptableRenderContext context, List<Camera> cameras) {
        for (int i = 0; i < cameras.Count; i++) {
	        var camera = cameras[i];
            context.SetupCameraProperties(camera);
            context.DrawSkybox(camera);
            context.Submit();
		}
    }
}
```

## 几何绘制

ScriptableRenderer
ScriptableRenderPass
ScriptableRendererFeature
ScriptableRendererData

在 ScriptableRenderer 中，若干 ScriptableRenderPass 被组织成 RenderBlocks。

ScriptableRenderer 在绘制时，通过 ExecuteBlock 方法先后绘制
- RenderPassBlock.BeforeRendering
- RenderPassBlock.MainRenderingOpaque
- RenderPassBlock.MainRenderingTransparent
- RenderPassBlock.AfterRendering

在每个 RenderBlock 的 ExecuteBlock 绘制中，遍历该 block 对应的 ScriptableRenderPass，通过 ExecuteRenderPass 方法，调用每个 ScriptableRenderPass 的 Execute

ScriptableRendererFeature 用来向 renderer 注入 ScriptableRenderPass 

### Render Pass
DrawingSettings

## SRP Batcher

https://docs.unity.cn/cn/2019.4/Manual/SRPBatcher.html

- 通过批处理一系列 Bind 和 Draw GPU 命令来减少 DrawCall 之间的 GPU 设置
- 相同着色器的不同材质参数一次提交到大的 cbuffer，DrawCall 前通过 cbuffer 偏移地址做绑定