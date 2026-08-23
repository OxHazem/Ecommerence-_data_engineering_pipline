from Data_generator.exchange_rate.service import (
    ExchangeRateService
)


def test_egp_to_egp():

    service = ExchangeRateService()

    result = service.get_rate("EGP", "EGP")

    assert result["rate"] == 1


def test_sar_to_egp():

    service = ExchangeRateService()

    result = service.get_rate("SAR", "EGP")

    assert result["base"] == "SAR"
    assert result["quote"] == "EGP"
    assert result["rate"] > 0


def test_aed_to_egp():

    service = ExchangeRateService()

    result = service.get_rate("AED", "EGP")

    assert result["base"] == "AED"
    assert result["quote"] == "EGP"
    assert result["rate"] > 0


def test_unsupported_currency():

    service = ExchangeRateService()

    try:
        service.get_rate("USD", "EGP")
        assert False, "Expected ValueError"

    except ValueError:
        pass


if __name__ == "__main__":

    test_egp_to_egp()
    test_sar_to_egp()
    test_aed_to_egp()
    test_unsupported_currency()

    print("Exchange Rate Service tests passed.")