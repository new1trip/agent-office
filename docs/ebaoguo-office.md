# 易包裹 AI 办公室

入口：https://office.ebaoguo.com 。上游项目仍为 AgentSystemLabs/agent-office，保留 MIT 许可。

## 首次使用

1. 管理员打开专属邀请链接，自行设置密码；邀请一次有效、七天到期。不要公开管理员邀请链接。
2. 登录后在菜单的账号管理邀请指定成员，各自设置密码。共享密码登录已关闭。
3. 添加需要工作的 GitHub 项目，每个项目成为一层。服务器初始没有业务仓库或 AI 凭据；本地演示楼层没有部署到线上。
4. 在自己的账号下完成 GitHub 与 AI 提供商授权，再分配真实任务。未授权前不能声称已有开发任务运行。
5. 顶部“🎵 音乐”打开点唱机。“播放华语经典 · MELODY”接入直播，包含 80／90 年代歌曲，也有其他年代节目；个人音量与静音可独立设置，首次访问静音。同楼层共享选台。电台由第三方提供，可能有地域限制或中断，支持打开官方播放器。

## 运维

部署实现与回滚见 [部署目录说明](../deploy/office-ebaoguo/README.md)。使用独立 agentoffice 系统账号、localhost:4700、Nginx 与 Let's Encrypt，服务为 ebaoguo-office.service。业务站点和原有本地办公室独立。

所有写入、重启、reload 和部署冒烟通过共享 coord.py deploy 保护，不直接覆盖 live。备份和初始邀请保存在服务器 /root/ewe-baks/office-ebaoguo-20261023-1ec2da0，成功部署备份为 /root/ewe-baks/office-ebaoguo-20261023-9b8f161。运行代码提交为 9b8f161；业务数据库未修改。首次两次探测失败均已回滚，最终 HTTPS 与个人登录保护通过。

证书自动续期，部署 hook 先 nginx -t 再 reload。服务器 DNS 缓存可能短时保留 NXDOMAIN，部署探测通过 --resolve 指定已确认的 IP，保留正常 TLS 主机名校验。

仓库从上游 fork 为 new1trip/agent-office；origin 指向 fork，upstream 保留原仓库。初次部署协调清单的 repo key 仍是 git:github.com/AgentSystemLabs/agent-office（原任务登记时身份）。后续部署必须同时核对该历史清单，并保证包含 9b8f161，不能因 fork 的新身份而遗漏生产版本。

账号不是项目级 OS 沙箱：团队成员可以操作该办公室专用系统账号可访问的项目。不要把敏感业务密钥或 root 凭据放入办公室。真实项目接入、提供商登录和真实任务端到端验证仍待管理员完成。
