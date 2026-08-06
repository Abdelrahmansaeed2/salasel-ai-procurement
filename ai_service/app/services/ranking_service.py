import math

from app.agents.state import Candidate


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def blend_and_rank(
    candidates: list[dict],
    weights: dict[str, float],
    customer_location: tuple[float, float],
    radius_km: float = 50.0,
) -> list[Candidate]:
    scored: list[tuple[float, Candidate]] = []
    for c in candidates:
        payload = c.get("payload", {}) or {}
        geo = payload.get("geo") or {}
        lat = geo.get("lat")
        lon = geo.get("lon")
        if lat is not None and lon is not None:
            distance_km = haversine_km(
                customer_location[0], customer_location[1], float(lat), float(lon)
            )
        else:
            distance_km = radius_km

        quality_score = float(payload.get("quality_score") or 0)
        similarity_score = float(c.get("similarity_score") or 0)

        normalized_distance = 1 - (distance_km / radius_km) if radius_km > 0 else 0
        blended = (
            weights.get("sim", 1.0) * similarity_score
            + weights.get("quality", 0.7) * quality_score
            + weights.get("distance", 0.5) * normalized_distance
        )

        ranked = Candidate(
            product_id=str(c.get("product_id", "")),
            supplier_id=str(payload.get("supplier_id", "")),
            similarity_score=similarity_score,
            quality_score=quality_score,
            distance_km=distance_km,
            price=float(payload.get("price") or 0),
        )
        scored.append((blended, ranked))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [s[1] for s in scored[:5]]
