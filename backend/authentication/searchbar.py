from bisect import bisect_left
from typing import List

def search_societies(query: str, societies: List[str], limit: int = 20) -> List[str]:

q = (query or "").strip().lower()
if not q:
    return []

societies_sorted = sorted(societies, key=lambda s: s.lower())

# Use binary search to find the starting index of matches