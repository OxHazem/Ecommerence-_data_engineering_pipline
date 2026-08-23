from Data_generator.exchange_rate.api_client import (
    ExchangeRateAPIClient
)


def test_get_current_rate():

    client = ExchangeRateAPIClient()

    result = client.get_rate(
        "SAR",
        "EGP"
    )

    assert result["base"] == "SAR"
    assert result["quote"] == "EGP"
    assert result["rate"] > 0


if __name__ == "__main__":
    test_get_current_rate()
    print("API test passed.")