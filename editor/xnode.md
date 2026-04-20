# xNode

https://github.com/Siccity/xNode

https://github.com/KAJed82/xNode

## 端口

### 动态输入输出端口

NodeDataCache.cs 在初始化 PortDataCache 时，遍历各类型的 Node 所包含的序列号输入输出端口，构造Node类型-端口列表字典 portDataCache
```csharp
private static void CachePorts(System.Type nodeType) {
    List<System.Reflection.FieldInfo> fieldInfo = GetNodeFields(nodeType);

    for (int i = 0; i < fieldInfo.Count; i++) {

        //Get InputAttribute and OutputAttribute
        object[] attribs = fieldInfo[i].GetCustomAttributes(true);
        Node.InputAttribute inputAttrib = attribs.FirstOrDefault(x => x is Node.InputAttribute) as Node.InputAttribute;
        Node.OutputAttribute outputAttrib = attribs.FirstOrDefault(x => x is Node.OutputAttribute) as Node.OutputAttribute;

        if (inputAttrib == null && outputAttrib == null) continue;

        if (inputAttrib != null && outputAttrib != null) Debug.LogError("Field " + fieldInfo[i].Name + " of type " + nodeType.FullName + " cannot be both input and output.");
        else {
            if (!portDataCache.ContainsKey(nodeType)) portDataCache.Add(nodeType, new List<NodePort>());
            portDataCache[nodeType].Add(new NodePort(fieldInfo[i]));
        }
    }
}
```

### 类型约束

NodePorts.cs 检查是否可以建立连接
```csharp
/// <summary> Returns true if this port can connect to specified port </summary>
public bool CanConnectTo(NodePort port) {
    // Figure out which is input and which is output
    NodePort input = null, output = null;
    if (IsInput) input = this;
    else output = this;
    if (port.IsInput) input = port;
    else output = port;
    // If there isn't one of each, they can't connect
    if (input == null || output == null) return false;
    // Check input type constraints
    if (input.typeConstraint == XNode.Node.TypeConstraint.Inherited && !input.ValueType.IsAssignableFrom(output.ValueType)) return false;
    if (input.typeConstraint == XNode.Node.TypeConstraint.Strict && input.ValueType != output.ValueType) return false;
    if (input.typeConstraint == XNode.Node.TypeConstraint.InheritedInverse && !output.ValueType.IsAssignableFrom(input.ValueType)) return false;
    // Check output type constraints
    if (output.typeConstraint == XNode.Node.TypeConstraint.Inherited && !input.ValueType.IsAssignableFrom(output.ValueType)) return false;
    if (output.typeConstraint == XNode.Node.TypeConstraint.Strict && input.ValueType != output.ValueType) return false;
    if (output.typeConstraint == XNode.Node.TypeConstraint.InheritedInverse && !output.ValueType.IsAssignableFrom(input.ValueType)) return false;
    // Success
    return true;
}
```

## GUI绘制

NodeEditorWindow.OnGUI 方法用来绘制节点图，它包含

- 绘制背景网格
- 绘制连线
- 绘制节点
- 绘制其它

```csharp
public partial class NodeEditorWindow {
    protected virtual void OnGUI() {
        Event e = Event.current;
        DrawGrid(position, zoom, panOffset);
        if (e.type == EventType.Repaint)
        {
            DrawConnections();
            DrawDraggedConnection();
        }
        BeginZoomed();
        {
            DrawNodes();
            DrawTooltip();
        }
        EndZoomed();

        graphEditor.OnGUI();
    }
}
```

### 单个节点

NodeEditorBase.cs 中的 NodeEditorBase<T, A, K> 定义了一编辑器类型、属性类型、节点类型的组合关系。并提供了 NodeEditor 实现：

```csharp
public class NodeEditor : XNodeEditor.Internal.NodeEditorBase<NodeEditor, NodeEditor.CustomNodeEditorAttribute, XNode.Node>
```

NodeEditorBase 提供了 GetEditor 方法，返回节点实例对应的编辑器实例。如果不派生 NodeEditor，NodeEditor.GetEditor 返回的就是它自己

```csharp
public static T GetEditor(K target, NodeEditorWindow window) {
    if (target == null) return null;
    T editor;
    if (!editors.TryGetValue(target, out editor)) {
        Type type = target.GetType();
        Type editorType = GetEditorType(type);
        editor = Activator.CreateInstance(editorType) as T;
        editor.target = target;
        editor.serializedObject = new SerializedObject(target);
        editor.window = window;
        editor.OnCreate();
        editors.Add(target, editor);
    }
    if (editor.target == null) editor.target = target;
    if (editor.window != window) editor.window = window;
    if (editor.serializedObject == null) editor.serializedObject = new SerializedObject(target);
    return editor;
}
```

### 连线

NodeEditorWindow.DrawConnections 绘制节点出口、入口间的连线。其使用的绘图 API 是 UnityEditor.Handles.DrawAAPolyLine

```csharp
public void DrawConnections() {
    foreach (XNode.Node node in graph.nodes) {
        foreach (XNode.NodePort output in node.Outputs) {
            for (int k = 0; k < output.ConnectionCount; k++) {
                XNode.NodePort input = output.GetConnection(k);
                gridPoints.Clear();
                gridPoints.Add(portStartWindow);
                foreach (var v in reroutePoints)
                    gridPoints.Add(GridToWindowPosition(v));
                gridPoints.Add(portEndWindow);
                DrawNoodle(noodleGradient, noodlePath, noodleStroke, noodleThickness, gridPoints);
            }
        }
    }
}

public void DrawNoodle(Gradient gradient, NoodlePath path, NoodleStroke stroke, float thickness, List<Vector2> gridPoints) {
    switch (path) {
        case NoodlePath.Curvy:
            for (int i = 0; i < length - 1; i++) {
                int division = Mathf.RoundToInt(.2f * dist_ab) + 3;
                for (int j = 1; j <= division; ++j) {
                    DrawAAPolyLineNonAlloc(thickness, bezierPrevious, bezierNext);
                }
            }
        case NoodlePath.Straight:
            for (int i = 0; i < length - 1; i++) {
                int segments = (int) Vector2.Distance(point_a, point_b) / 5;
                for (int j = 0; j <= segments; j++) {
                    DrawAAPolyLineNonAlloc(thickness, prev_point, lerp);
                }
            }
        case NoodlePath.Angled:
            for (int i = 0; i < length - 1; i++) {
                DrawAAPolyLineNonAlloc()
            }
        case NoodlePath.ShaderLab:
            for (int i = 0; i < length - 1; i++) {
                int segments = (int) Vector2.Distance(point_a, point_b) / 5;
                for (int j = 0; j <= segments; j++) {
                    DrawAAPolyLineNonAlloc(thickness, prev_point, lerp);
                }
            }
    }
}

```