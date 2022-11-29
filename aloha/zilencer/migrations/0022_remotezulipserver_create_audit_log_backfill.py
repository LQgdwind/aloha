from django.db import migrations
from django.db.backends.postgresql.schema import BaseDatabaseSchemaEditor
from django.db.migrations.state import StateApps


def backfill_remote_aloha_server_creation_log_events(
    apps: StateApps, schema_editor: BaseDatabaseSchemaEditor
) -> None:
    RemoteAlohaServer = apps.get_model("zilencer", "RemoteAlohaServer")
    RemoteAlohaServerAuditLog = apps.get_model("zilencer", "RemoteAlohaServerAuditLog")
    RemoteAlohaServerAuditLog.REMOTE_SERVER_CREATED = 10215

    objects_to_create = []
    for remote_server in RemoteAlohaServer.objects.all():
        entry = RemoteAlohaServerAuditLog(
            server=remote_server,
            event_type=RemoteAlohaServerAuditLog.REMOTE_SERVER_CREATED,
            event_time=remote_server.last_updated,
            backfilled=True,
        )
        objects_to_create.append(entry)
    RemoteAlohaServerAuditLog.objects.bulk_create(objects_to_create)


def reverse_code(apps: StateApps, schema_editor: BaseDatabaseSchemaEditor) -> None:
    RemoteAlohaServerAuditLog = apps.get_model("zilencer", "RemoteAlohaServerAuditLog")
    RemoteAlohaServerAuditLog.REMOTE_SERVER_CREATED = 10215
    RemoteAlohaServerAuditLog.objects.filter(
        event_type=RemoteAlohaServerAuditLog.REMOTE_SERVER_CREATED, backfilled=True
    ).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("zilencer", "0021_alter_remotealohaserver_uuid"),
    ]

    operations = [
        migrations.RunPython(
            backfill_remote_aloha_server_creation_log_events,
            reverse_code=reverse_code,
            elidable=True,
        )
    ]
