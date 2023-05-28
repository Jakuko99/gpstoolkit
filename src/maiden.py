def to_maiden(lat: float, lon: float = None, precision: int = 3):
    """
        lat : float or tuple of float
            latitude or tuple of latitude, longitude
        lon : float, optional
            longitude (if not given tuple)
        precision : int, optional
            level of precision (length of maidenhead grid string output)
    """
    try:
        A = ord("A")
        a = divmod(lon + 180, 20)
        b = divmod(lat + 90, 10)
        maiden = chr(A + int(a[0])) + chr(A + int(b[0]))
        lon = a[1] / 2.0
        lat = b[1]
        i = 1
        while i < precision:
            i += 1
            a = divmod(lon, 1)
            b = divmod(lat, 1)
            if not (i % 2):
                maiden += str(int(a[0])) + str(int(b[0]))
                lon = 24 * a[1]
                lat = 24 * b[1]
            else:
                maiden += chr(A + int(a[0])) + chr(A + int(b[0]))
                lon = 10 * a[1]
                lat = 10 * b[1]

        if len(maiden) >= 6:
            maiden = maiden[:4] + maiden[4:6].lower() + maiden[6:]

        return maiden.upper()
    except (TypeError, ValueError):
    	return "-"

def to_location(maiden: str, center: bool = True):
    maiden = maiden.strip().upper()

    N = len(maiden)
    if not ((8 >= N >= 2) and (N % 2 == 0)):
        raise ValueError("Maidenhead locator requires 2-8 characters, even number of characters")

    Oa = ord("A")
    lon = -180.0
    lat = -90.0
    lon += (ord(maiden[0]) - Oa) * 20
    lat += (ord(maiden[1]) - Oa) * 10
    if N >= 4:
        lon += int(maiden[2]) * 2
        lat += int(maiden[3]) * 1
    if N >= 6:
        lon += (ord(maiden[4]) - Oa) * 5.0 / 60
        lat += (ord(maiden[5]) - Oa) * 2.5 / 60
    if N >= 8:
        lon += int(maiden[6]) * 5.0 / 600
        lat += int(maiden[7]) * 2.5 / 600

    if center:
        if N == 2:
            lon += 20 / 2
            lat += 10 / 2
        elif N == 4:
            lon += 2 / 2
            lat += 1.0 / 2
        elif N == 6:
            lon += 5.0 / 60 / 2
            lat += 2.5 / 60 / 2
        elif N >= 8:
            lon += 5.0 / 600 / 2
            lat += 2.5 / 600 / 2

    return lat, lon
