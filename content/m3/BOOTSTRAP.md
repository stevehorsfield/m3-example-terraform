# Overview

An M3DB cluster must be initialised after deployment.

See https://m3db.github.io/m3/how_to/cluster_hard_way/.

## Topology

On a data node, launch the m3 coordinator:

```
systemctl start m3-coordinator.service
```

Then create an initial placement:

```
curl -X POST localhost:7201/api/v1/placement/init -d '{
    "num_shards": 32,
    "replication_factor": 3,
    "instances": [
        {
            "id": "m3-data0.example.local",
            "isolation_group": "us-east-1a",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3-data0.example.local:9000",
            "hostname": "m3-data0.example.local",
            "port": 9000
        },
        {
            "id": "m3-data1.example.local",
            "isolation_group": "us-east-1b",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3-data1.example.local:9000",
            "hostname": "m3-data1.example.local",
            "port": 9000
        },
        {
            "id": "m3-data2.example.local",
            "isolation_group": "us-east-1c",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3-data2.example.local:9000",
            "hostname": "m3-data2.example.local",
            "port": 9000
        }
    ]
}'
```

# Namespace

An initial namespace can be added using:

```
curl -XPOST http://localhost:7201/api/v1/database/namespace -d '{
  "name": "default",
  "options": {
    "bootstrapEnabled": true,
    "flushEnabled": true,
    "writesToCommitLog": true,
    "cleanupEnabled": true,
    "snapshotEnabled": true,
    "repairEnabled": false,
    "retentionOptions": {
      "retentionPeriodDuration": "792h",
      "blockSizeDuration": "3h",
      "bufferFutureDuration": "10m",
      "bufferPastDuration": "10m",
      "blockDataExpiry": true,
      "blockDataExpiryAfterNotAccessPeriodDuration": "5m"
    },
    "indexOptions": {
      "enabled": true,
      "blockSizeDuration": "6h"
    }
  }
}'
```

Two aggregated namespaces can be added using:

```
curl -XPOST http://localhost:7201/api/v1/database/namespace/create -d '{
    "namespaceName": "agg_100days_1h",
    "retentionTime": "2400h"
}'

curl -XPOST http://localhost:7201/api/v1/database/namespace/create -d '{
    "namespaceName": "agg_1year_4h",
    "retentionTime": "17520h"
}'
```
