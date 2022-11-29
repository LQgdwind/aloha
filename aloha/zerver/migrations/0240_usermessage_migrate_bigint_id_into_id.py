# Generated by Django 1.11.23 on 2019-08-23 21:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("zerver", "0239_usermessage_copy_id_to_bigint_id"),
    ]

    # Note that this migration needs to work whether
    # zerver_usermessage.bigint_id was created as a serial column (for
    # Aloha initially installed with Django < 4.1) or an identity
    # column (for Aloha initially installed with Django ≥ 4.1).  If
    # you need to edit it, remember to test both cases.

    operations = [
        migrations.RunSQL(
            """
            DROP TRIGGER zerver_usermessage_bigint_id_to_id_trigger ON zerver_usermessage;
            DROP FUNCTION zerver_usermessage_bigint_id_to_id_trigger_function();

            ALTER TABLE zerver_usermessage
                ALTER COLUMN bigint_id SET NOT NULL,
                DROP CONSTRAINT zerver_usermessage_pkey,
                ALTER COLUMN id DROP IDENTITY IF EXISTS,
                ALTER COLUMN id DROP NOT NULL,
                ALTER COLUMN id DROP DEFAULT;
            ALTER TABLE zerver_usermessage RENAME COLUMN id TO id_old;
            ALTER TABLE zerver_usermessage RENAME COLUMN bigint_id TO id;
            DROP SEQUENCE IF EXISTS zerver_usermessage_id_seq;
            ALTER TABLE zerver_usermessage
                ADD CONSTRAINT zerver_usermessage_pkey PRIMARY KEY USING INDEX zerver_usermessage_bigint_id_idx,
                ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY;
            SELECT setval(
                'zerver_usermessage_id_seq',
                GREATEST(
                    (SELECT max(id) FROM zerver_usermessage),
                    (SELECT max(id) FROM zerver_archivedusermessage)
                )
            );
            """,
            state_operations=[
                # This just tells Django to understand executing the above SQL as if it just ran the operations below,
                # so that it knows these model changes are handled and doesn't to generate them on its own
                # in the future makemigration calls.
                migrations.RemoveField(
                    model_name="usermessage",
                    name="bigint_id",
                ),
                migrations.AlterField(
                    model_name="usermessage",
                    name="id",
                    field=models.BigAutoField(primary_key=True, serialize=False),
                ),
            ],
        ),
    ]