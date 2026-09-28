# MoonUUID

[![CI](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml/badge.svg)](https://github.com/wulisususu/MoonUUID/actions/workflows/ci.yml)

**面向 MoonBit 的 RFC 9562 UUID 基础库。**

支持 UUIDv3 / v4 / v5 / v6 / v7 / v8、严格单调 UUIDv7、安全随机熵、可注入时钟与熵源、文本/二进制互操作，以及 wasm / wasm-gc / JavaScript / native 多后端验证。

MoonUUID 的定位是可复用的基础设施库，而不是某个具体业务项目的内部工具。它适合被 Web 服务、数据库层、事件系统、CLI、存储适配器和其他 MoonBit 库直接依赖。

- 标准：RFC 9562
- 模块：`wulisususu/moonuuid`
- 当前版本：`0.1.0`
- 发布状态：已发布至 Mooncakes，并通过独立 Consumer 安装验证
- 许可证：Apache-2.0
- 支持目标：`wasm`、`wasm-gc`、`js`、`native`

## 为什么是 MoonUUID

MoonBit 生态中已经存在 UUID 实现，MoonUUID 并不以“生态中没有 UUID 库”为前提。

本项目的独立价值主要集中在：

- 面向 RFC 9562 的 v3 / v4 / v5 / v6 / v7 / v8 支持；
- 默认随机生成使用安全熵源，不在失败时静默退化到弱随机；
- 时钟与熵源可注入，便于确定性测试；
- 提供状态化单调 UUIDv7 生成器；
- 处理同一毫秒连续生成、系统时钟回拨和计数进位；
- 单调空间耗尽时显式返回错误；
- 严格解析与宽松互操作解析分离；
- 同一套公共 API 在 MoonBit 多后端持续验证。

详细差异见 [与现有实现的差异](docs/DIFFERENTIATION.md)，运行时与后端行为见 [兼容性说明](docs/COMPATIBILITY.md)。

## 安装

MoonUUID `0.1.0` 已发布到 Mooncakes，可直接安装：

```bash
moon add wulisususu/moonuuid@0.1.0
```

在包中导入：

```moonbit
import {
  "wulisususu/moonuuid" @uuid
}
```

## 快速开始

### 生成 UUIDv7

```moonbit
match @uuid.v7() {
  Ok(id) => println(@uuid.to_string(id))
  Err(_) => println("secure entropy unavailable")
}
```

### 生成确定性的资源 ID

同一个 Namespace 和名称会得到相同的 UUIDv5：

```moonbit
let id = @uuid.v5_string(
  @uuid.namespace_url(),
  "https://example.com/users/42",
)
println(@uuid.to_string(id))
```

### 解析 UUID

严格解析只接受标准 `8-4-4-4-12` 格式：

```moonbit
let strict = @uuid.parse(
  "017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
)
```

需要兼容 URN、32 位紧凑形式或花括号形式时，可使用：

```moonbit
let interoperable = @uuid.parse_permissive(
  "urn:uuid:017f22e2-79b0-7cc3-98c4-dc0c0c07398f",
)
```

### 严格单调 UUIDv7

```moonbit
let generator = @uuid.V7Generator::new()
let next_id = generator.next()
```

`V7Generator` 会在单进程内处理同毫秒连续生成和时钟回拨，保证后续 UUID 严格递增；计数空间耗尽时返回显式错误。

## 功能一览

| 能力 | 状态 | 主要 API |
| --- | --- | --- |
| Canonical UUID 解析/格式化 | ✅ | `parse`、`to_string` |
| Compact / URN / Braced 文本 | ✅ | `parse_permissive`、`to_urn`、`to_braced_string` |
| 16 字节网络序互操作 | ✅ | `to_bytes`、`from_bytes` |
| UUIDv3 | ✅ | `v3`、`v3_string` |
| UUIDv4 | ✅ | `v4`、`v4_with_entropy`、`v4_from_entropy` |
| UUIDv5 | ✅ | `v5`、`v5_string` |
| UUIDv6 | ✅ | `v6_from_parts` |
| UUIDv7 | ✅ | `v7`、`v7_with`、`v7_from_parts` |
| 单调 UUIDv7 | ✅ | `V7Generator` |
| UUIDv8 自定义字段 | ✅ | `v8_from_parts` |
| SHA-256 UUIDv8 示例 Profile | ✅ | `v8_sha256`、`v8_sha256_string` |
| 标准 Namespace | ✅ | DNS / URL / OID / X.500 |
| Nil / Max / Version / Variant | ✅ | 检查辅助函数 |
| RFC 9562 测试向量 | ✅ | v3 / v4 / v5 / v6 / v7 / v8 |
| Property-style 不变量测试 | ✅ | 文本/二进制 round-trip、单调性等 |
| 多后端 CI | ✅ | wasm / wasm-gc / js / Linux native / Windows native |

## UUIDv7 的安全与单调策略

默认 `v7()` 使用 MoonBit 的 Wall Clock 和平台安全熵源。

如果当前运行环境无法提供安全随机数，MoonUUID 会返回错误，而不是自动改用 `Math.random`、时间戳或普通 PRNG。

`V7Generator` 额外处理：

- 同一毫秒内连续生成多个 UUID；
- 系统时钟短暂回拨；
- `rand_b` 溢出后向 `rand_a` 进位；
- 完整 74-bit 单调 Payload 空间耗尽时返回 `MonotonicOverflow`。

同时提供 Provider Injection API，使时钟与随机输入可以在测试中完全确定。

## 二进制与文本互操作

MoonUUID 支持：

- canonical：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- compact：32 位十六进制
- URN：`urn:uuid:...`
- braced：`{...}`
- RFC/network-order 16 字节二进制形式

严格接口与兼容接口分开，避免为了接受更多输入格式而削弱核心解析约束。

## 实际使用示例

仓库中的 [examples/](examples/) 都是可运行的 MoonBit Package：

- **Web Request ID**：使用 UUIDv7 生成类似 `X-Request-ID` 的请求标识；
- **Database Key**：使用 `V7Generator` 生成严格递增的 UUIDv7；
- **Deterministic Resource ID**：使用 UUIDv5 根据 Namespace 和资源名称稳定派生 ID；
- **Wire Interoperability**：演示 URN → UUID → 16-byte → UUID → canonical string。

运行：

```bash
moon run examples/web_request_id --target native
moon run examples/database_key --target native
moon run examples/deterministic_resource_id --target native
moon run examples/interop --target native
```

## 仓库结构

```text
MoonUUID/
├─ uuid.mbt                 # Uuid 核心类型、解析、格式化、字节转换
├─ v4.mbt                   # UUIDv4
├─ v6.mbt                   # UUIDv6
├─ v7.mbt                   # UUIDv7 与 V7Generator
├─ v8.mbt                   # UUIDv8
├─ name_based.mbt           # UUIDv3 / UUIDv5 / SHA-256 UUIDv8
├─ namespace.mbt            # DNS / URL / OID / X.500 Namespace
├─ *_test.mbt               # 各模块对应测试
├─ property_test.mbt        # 批量不变量与 round-trip 测试
├─ examples/                # 可执行使用示例
├─ benchmarks/              # Release 模式 Benchmark
├─ docs/                    # API、兼容性、发布与设计文档
└─ .github/workflows/       # 多后端 CI 与 Mooncakes 发布流程
```

核心源码保持按能力拆分，每个主要实现文件都有对应测试文件。当前仓库没有遗留 TODO / FIXME / HACK 标记。

## 跨平台验证

CI 持续检查：

- WebAssembly
- WebAssembly GC
- JavaScript
- Linux native
- Windows native

需要注意：安全熵是否可用最终取决于运行宿主。

如果宿主无法提供安全熵，随机 UUID 生成接口会显式失败；解析、格式化、Name-based UUID、字段构造和 Provider Injection 等确定性能力仍然可以使用。

## 测试与验证

本地快速验证：

```bash
moon update
moon check --target native --deny-warn
moon test --target native
```

完整 CI 主要执行：

```bash
moon fmt --check
moon check --target <wasm|wasm-gc|js|native> --deny-warn
moon test --target <wasm|wasm-gc|js|native>
moon build --target <wasm|wasm-gc|js|native>
moon info --target native
moon package --list
moon bench benchmarks --release --target native --deny-warn
```

Windows native 由独立 Runner 执行检查与测试。

## Benchmark

仓库提供 Release 模式基准测试，覆盖：

- canonical parse
- canonical format
- UUIDv4 construction
- UUIDv5 derivation
- UUIDv7 construction

运行：

```bash
moon bench benchmarks --release --target native --deny-warn
```

具体方法和当前记录见 [Benchmark 文档](docs/BENCHMARKS.md)。

## 发布状态

MoonUUID `0.1.0` 已作为首个公开版本发布：

```text
Mooncakes: wulisususu/moonuuid@0.1.0
GitHub Release: v0.1.0
Release commit: 376775dec4990f82b12a927d647caf5432d16d98
```

发布流程在上传成功后还会创建一个全新的 MoonBit Consumer，从 Mooncakes 安装 `wulisususu/moonuuid@0.1.0`，完成编译并运行 UUID round-trip。

因此当前版本已经验证了：

```text
发布到 Mooncakes
        ↓
外部项目 moon add
        ↓
导入 MoonUUID
        ↓
编译
        ↓
实际运行
```

## 文档

- [评审证据汇总](docs/REVIEW_EVIDENCE.md)
- [API 参考](docs/API.md)
- [与现有 MoonBit UUID 实现的差异](docs/DIFFERENTIATION.md)
- [兼容性矩阵](docs/COMPATIBILITY.md)
- [文本与二进制格式](docs/FORMATS.md)
- [UUIDv4](docs/V4.md)
- [UUIDv7 与单调生成](docs/V7.md)
- [UUIDv6 / UUIDv8](docs/V6_V8.md)
- [Name-based UUID](docs/NAME_BASED.md)
- [Benchmark](docs/BENCHMARKS.md)
- [发布与 Mooncakes](docs/RELEASE.md)
- [评审说明](docs/CONTEST.md)

## 项目边界

MoonUUID 只负责 UUID 基础能力。

它不是：

- ORM
- 数据库驱动
- Web Framework
- Tracing System
- 分布式 ID 服务
- 工作流引擎

这些系统可以作为 MoonUUID 的上层消费者。

项目目前也不宣称不存在证据的生产环境用户、真实流量或大规模第三方采用情况；当前可验证的外部证据是 Mooncakes 正式发布和独立 Consumer Registry Smoke Test。

## 许可证

Apache-2.0
