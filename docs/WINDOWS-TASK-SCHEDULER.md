# Agendador De Tarefas Do Windows

O Project Backup Pilot pode instalar uma tarefa agendada para executar o backup automaticamente.

Nome padrao da tarefa:

```text
Project Backup Pilot
```

Configuracao recomendada:

- executar com privilegios mais altos
- usar o usuario atual do Windows
- iniciar quando disponivel
- repetir a cada quantidade de horas configurada

Validacao manual:

```powershell
Start-ScheduledTask -TaskName "Project Backup Pilot"
Get-ScheduledTaskInfo -TaskName "Project Backup Pilot"
```
