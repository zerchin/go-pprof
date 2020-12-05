# go-pprof

基于golang镜像构建一个可以使用pprof工具的镜像，并添加了graphviz和flameGraph工具快速生成可视化火焰图

> flameGraph基于此github：https://github.com/brendangregg/FlameGraph.git



## 使用方法

### 采集kubelet火焰图

1. 使用kubectl proxy命令开启debug

```bash
kubectl proxy --accept-hosts='^*$' [--address='0.0.0.0']
```

基于实际情况添加address参数



2. 启动go-pprof容器

```bash
docker run -itd --name go-pprof --net host zerchin/go-pprof
```



3. 使用go pprof工具导出采集的指标
   `kubectl proxy`的默认端口是8001，对该指标进行采集

```bash
docker exec -it go-pprof bash
go tool pprof -seconds=60 -raw -output=kubelet.pprof http://127.0.0.1:8001/api/v1/nodes/${NODENAME}/proxy/debug/pprof/profile
```

这里等待60s后，会将这60s内相关的函数调用输出到当前目录的kubelet.pprof文件中。



4. 将输出的文件转化成火焰图

```bash
stackcollapse-go.pl kubelet.pprof > kubelet.out
flamegraph.pl kubelet.out > kubelet.svg
```

最后生成的火焰图直接在浏览器打开即可



### 采集apiserver内存指标

1. 较新的k8s版本，默认关闭了pprof，需要手动开启，例如rancher/rke部署的集群，在`cluster.yml`配置文件中添加如下参数：

```yaml
services:
  kube-api:
    extra_args:
      profiling: true    ## 添加改参数
```

查看是否生效

```bash
ps aux|grep apiserver |grep profiling 
```



2. 使用kubectl proxy命令开启debug

```bash
kubectl proxy
```



3. 启动go-pprof容器

```bash
docker run -itd --name go-pprof --net host zerchin/go-pprof
```



4. 使用pprof工具采集内存指标

```bash
docker exec -it go-pprof bash
go tool pprof --http 0.0.0.0:9091 127.0.0.1:8001/debug/pprof/heap
go tool pprof --http 0.0.0.0:9091 127.0.0.1:8001/debug/pprof/allocs
```

这里会依赖graphviz，镜像默认已经安装了这个软件包



5. 最后在浏览器上打开IP:9091，即可看到内存相关情况，例如Top、Graph、Flame Graph、Peek、Source、Disassemble等图标
