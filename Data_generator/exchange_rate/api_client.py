# Data_generator/exchange_rate/api_client.py

from datetime import date
from decimal import Decimal

import requests

from .config import API_BASE_URL, API_TIMEOUT


class ExchangeRateAPIClient:
    """
    Client for the Frankfurter Exchange Rate API.
    """

    def __init__(
        self,
        base_url=API_BASE_URL,
        timeout=API_TIMEOUT
    ):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def get_rate(
        self,
        from_currency,
        to_currency,
        rate_date=None
    ):
        """
        Get an exchange rate between two currencies.

        Parameters
        ----------
        from_currency : str
            Source currency, e.g. SAR.

        to_currency : str
            Target currency, e.g. EGP.

        rate_date : str or datetime.date, optional
            Historical date in YYYY-MM-DD format.

        Returns
        -------
        dict
            Exchange-rate information.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        url = (
            f"{self.base_url}/rate/"
            f"{from_currency}/{to_currency}"
        )

        params = {}

        if rate_date is not None:

            if isinstance(rate_date, date):
                rate_date = rate_date.isoformat()

            params["date"] = rate_date

        response = requests.get(
            url,
            params=params,
            timeout=self.timeout
        )

        response.raise_for_status()

        data = response.json()

        return {
            "date": data["date"],
            "base": data["base"],
            "quote": data["quote"],
            "rate": Decimal(str(data["rate"]))
        }