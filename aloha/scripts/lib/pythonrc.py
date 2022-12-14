try:
    from django.conf import settings  # noqa: F401

    from analytics.models import *  # noqa: F401, F403
    from zerver.models import *  # noqa: F401, F403
except Exception:
    import traceback

    print("\nException importing Aloha core modules on startup!")
    traceback.print_exc()
else:
    print("\nSuccessfully imported Aloha settings, models, and actions functions.")
