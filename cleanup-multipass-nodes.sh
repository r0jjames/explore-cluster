#/bin/bash

# -- CLEAN UP OLD VMS ---
echo "🧹 Stopping and deleting any existing Multipass nodes..."
multipass stop --all
multipass delete --all
multipass purge

echo "DONE."
