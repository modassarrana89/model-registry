# API Reference

## Client

```{eval-rst}
.. automodule:: model_registry
```

## Core

The core {py:class}`model_registry.core.ModelRegistryAPIClient` is a lower level client that tries to emulate the Go
gRPC client.
As it wraps the client provided by the generated module `mr_openapi`, it's also an async interface for the client.

To create a client you should use the {py:meth}`model_registry.core.ModelRegistryAPIClient.secure_connection` or {py:meth}`model_registry.core.ModelRegistryAPIClient.insecure_connection` constructor. E.g.

```py
from model_registry.core import ModelRegistryAPIClient

insecure_registry = ModelRegistryAPIClient.insecure_connection(
    "server-address", "port",
    # optionally, you can identify yourself
    # user_token=os.environ["MY_TOKEN"]
)

insecure_registry = ModelRegistryAPIClient.insecure_connection(
    "server-address", "port",
    user_token=os.environ["MY_TOKEN"]  # this is necessary on a secure connection
    # optionally, use a custom_ca
    # custom_ca=os.environ["MY_CERT"]
)
```

The {py:class}`model_registry.core.ModelRegistryAPIClient` manages an async connection for you, so you only need to set
up the client once, and only need to `await` when making calls -- how convenient!


### Register objects

```py
from model_registry.types import RegisteredModel, ModelVersion, ModelArtifact
from model_registry.utils import s3_uri_from

async def register_a_model():
    model = await registry.upsert_registered_model(
        RegisteredModel(
            name="HAL",
            owner="me <me@cool.inc>",
        )
    )
    assert model.id  # this should be valid now

    # we need a registered model to associate the version to
    version = await registry.upsert_model_version(
        ModelVersion(
            name="9000",
            author="Mr. Tom A.I.",
            external_id="HAL-9000",
        ),
        model.id
    )
    assert version.id

    # we need a version to associate a trained model to
    trained_model = await registry.upsert_model_artifact(
        ModelArtifact(
            name="HAL-core",
            uri=s3_uri_from("build/onnx/hal.onnx", "cool-bucket"),
            model_format_name="onnx",
            model_format_version="1",
            storage_key="secret_secret",
        ),
        version.id
    )
    assert trained_model.id
```

> Note: to execute the remaining examples, you should wrap them in an async function like shown above.
> Check out the [Python asyncio module docs](https://docs.python.org/3/library/asyncio.html)

As objects are only assigned IDs upon creation, you can use this property to verify whether an object exists.

### Query objects

There are several ways to get registered objects from the registry.

#### By ID

After upserting an object you can use its `id` to fetch it again.

```py
new_model = await registry.upsert_registered_model(RegisteredModel("new_model"))

maybe_new_model = await registry.get_registered_model_by_id(new_model.id)

assert maybe_new_model == new_model  # True
```

#### By parameters

External IDs can be used to query objects in the wild.
Note that external IDs must be unique among artifacts or contexts (see [Types](#types)).

```py
trained_model = ModelArtifact(
    name="my_model_name",
    uri="resource_URI",
    description="Model description",
    external_id="unique_reference"
)

# As a version is a context, we can have the same external_id as the above
version = ModelVersion(
    name="v1.0",
    author="model author",
    external_id="unique_reference"
)

# Registering this will cause an error!
# model = RegisteredModel(
#    name="my_model_name",
#    external_id="unique_reference",  # this wouldn't be unique
# )

model = RegisteredModel(
    name="my_model_name",
    external_id="another_unique_reference"
)
```

You can also perform queries by parameters:

```py
# We can get the model artifact associated to a version
another_trained_model = await registry.get_model_artifact_by_params(name="my_model_name", model_version_id=another_version.id)

# Or by its unique identifier
trained_model = await registry.get_model_artifact_by_params(external_id="unique_reference")

# Same thing for a version
version = await registry.get_model_version_by_params(external_id="unique_reference")

# Or for a model
model = await registry.get_registered_model_by_params(external_id="another_unique_reference")

# We can also get a version by its name and associated model id
version = await registry.get_model_version_by_params(version="v1.0", registered_model_id="x")

# And we can get a model by simply calling its name
model = await registry.get_registered_model_by_params(name="my_model_name")
```

### Query multiple objects

We can query all objects of a type

```py
models = await registry.get_registered_models()

versions = await registry.get_model_versions("registered_model_id")

# We can get a list of all model artifacts
all_model_artifacts = await registry.get_model_artifacts()
```

To limit or order the query, provide a {py:class}`model_registry.types.ListOptions` object.

```py
from model_registry import ListOptions

options = ListOptions(limit=50)

first_50_models = await registry.get_registered_models(options)

# By default we get ascending order
options = ListOptions.order_by_creation_time(is_asc=False)

last_50_models = await registry.get_registered_models(options)
```

```{eval-rst}
.. automodule:: model_registry.core
```

## Types

### Create objects

Registry objects can be created by doing

```py
from model_registry.types import ModelArtifact, ModelVersion, RegisteredModel

trained_model = ModelArtifact(
    name="model-exec",
    uri="resource_URI",
    description="Model description",
)

version = ModelVersion(
    name="v1.0",
    author="model author",
)

model = RegisteredModel(
    name="model",
    owner="team",
)
```

```{eval-rst}
.. automodule:: model_registry.types
```

## Exceptions

```{eval-rst}
.. automodule:: model_registry.exceptions
```
