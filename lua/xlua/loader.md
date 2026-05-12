# Lua 代码加载路径

在 LuaEnv.cs 中，提供了 AddLoader 方法，用于添加自定义的代码加载器。加载器用来支持 lua require 的加载逻辑。

```csharp
public delegate byte[] CustomLoader(ref string filepath);

internal List<CustomLoader> customLoaders = new List<CustomLoader>();

//loader : CustomLoader， filepath参数：（ref类型）输入是require的参数，如果需要支持调试，需要输出真实路径。
//                        返回值：如果返回null，代表加载该源下无合适的文件，否则返回UTF8编码的byte[]
public void AddLoader(CustomLoader loader)
{
    customLoaders.Add(loader);
}
```

CustomLoader 回调需要实现读文件功能，一般需要支持读取热更目录的 lua 文件

## Lua package searchers

在 xlua C API 中，xlua_getloaders 把 package 表的 searchers 返回给应用层（Lua 5.4）

```C
LUA_API void xlua_getloaders (lua_State *L) {
	lua_getglobal(L, "package");
#if LUA_VERSION_NUM == 501
    lua_getfield(L, -1, "loaders");
#else
	lua_getfield(L, -1, "searchers");
#endif
	lua_remove(L, -2);
}
```

C# 层的 AddSearcher 方法利用 xlua_getloaders 添加一个自定义的 searcher

```csharp
        private void AddSearcher(LuaCSFunction searcher, int index)
        {
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnvLock)
            {
#endif
                var _L = L;
                //insert the loader
                LuaAPI.xlua_getloaders(_L);
                if (!LuaAPI.lua_istable(_L, -1))
                {
                    throw new Exception("Can not set searcher!");
                }
                uint len = LuaAPI.xlua_objlen(_L, -1);
                index = index < 0 ? (int)(len + index + 2) : index;
                for (int e = (int)len + 1; e > index; e--)
                {
                    LuaAPI.xlua_rawgeti(_L, -1, e - 1);
                    LuaAPI.xlua_rawseti(_L, -2, e);
                }
                LuaAPI.lua_pushstdcallcfunction(_L, searcher);
                LuaAPI.xlua_rawseti(_L, -2, index);
                LuaAPI.lua_pop(_L, 1);
#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
        }
```

customLoaders 列表由 LoadFromCustomLoaders 函数遍历和调用加载

```csharp
[MonoPInvokeCallback(typeof(LuaCSFunction))]
internal static int LoadFromCustomLoaders(RealStatePtr L)
{
    try
    {
        string filename = LuaAPI.lua_tostring(L, 1);

        LuaEnv self = ObjectTranslatorPool.Instance.Find(L).luaEnv;

        foreach (var loader in self.customLoaders)
        {
            string real_file_path = filename;
            byte[] bytes = loader(ref real_file_path);
            if (bytes != null)
            {
                if (LuaAPI.xluaL_loadbuffer(L, bytes, bytes.Length, "@" + real_file_path) != 0)
                {
                    return LuaAPI.luaL_error(L, String.Format("error loading module {0} from CustomLoader, {1}",
                        LuaAPI.lua_tostring(L, 1), LuaAPI.lua_tostring(L, -1)));
                }
                return 1;
            }
        }
        LuaAPI.lua_pushstring(L, string.Format(
            "\n\tno such file '{0}' in CustomLoaders!", filename));
        return 1;
    }
    catch (System.Exception e)
    {
        return LuaAPI.luaL_error(L, "c# exception in LoadFromCustomLoaders:" + e);
    }
}
```