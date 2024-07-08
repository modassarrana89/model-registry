"""Model Registry REST API.

REST API for Model Registry to create and manage ML model metadata

The version of the OpenAPI document: v1alpha3
Generated by OpenAPI Generator (https://openapi-generator.tech)

Do not edit the class manually.
"""  # noqa: E501

import unittest

from mr_openapi.models.serve_model_list import ServeModelList


class TestServeModelList(unittest.TestCase):
    """ServeModelList unit test stubs."""

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def make_instance(self, include_optional) -> ServeModelList:
        """Test ServeModelList
        include_option is a boolean, when False only required
        params are included, when True both required and
        optional params are included.
        """
        # uncomment below to create an instance of `ServeModelList`
        """
        model = ServeModelList()
        if include_optional:
            return ServeModelList(
                next_page_token = '',
                page_size = 56,
                size = 56,
                items = [
                    mr_openapi.models.serve_model.ServeModel()
                    ]
            )
        else:
            return ServeModelList(
                next_page_token = '',
                page_size = 56,
                size = 56,
        )
        """

    def testServeModelList(self):
        """Test ServeModelList."""
        # inst_req_only = self.make_instance(include_optional=False)
        # inst_req_and_optional = self.make_instance(include_optional=True)


if __name__ == "__main__":
    unittest.main()