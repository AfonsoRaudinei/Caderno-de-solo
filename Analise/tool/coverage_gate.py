#!/usr/bin/env python3
"""Coverage thresholds for Gate E.

Reads LCOV and enforces:
1) Per-critical-file minimum line coverage.
2) Aggregate minimum line coverage across critical files.
3) Optional global minimum line coverage (if env provided).
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


def _read_lcov(path: Path) -> dict[str, tuple[int, int]]:
    records: dict[str, tuple[int, int]] = {}
    current: str | None = None
    lf = 0
    lh = 0
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if raw.startswith("SF:"):
            current = raw[3:]
            lf = 0
            lh = 0
        elif raw.startswith("LF:"):
            lf = int(raw[3:])
        elif raw.startswith("LH:"):
            lh = int(raw[3:])
        elif raw == "end_of_record" and current:
            records[current] = (lf, lh)
            current = None
    return records


def _pct(lf: int, lh: int) -> float:
    if lf <= 0:
        return 100.0
    return (lh / lf) * 100.0


def _fail(msg: str) -> None:
    print(f"[COVERAGE][FAIL] {msg}")
    sys.exit(1)


def main() -> int:
    lcov_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("coverage/lcov.info")
    if not lcov_path.exists():
        _fail(f"LCOV not found: {lcov_path}")

    records = _read_lcov(lcov_path)

    critical_files: list[tuple[str, float]] = [
        ("lib/main.dart", float(os.getenv("QUALITY_MIN_MAIN_COVERAGE", "25"))),
        ("lib/core/router/app_router.dart", float(os.getenv("QUALITY_MIN_ROUTER_COVERAGE", "50"))),
        (
            "lib/features/auth/presentation/login/login_controller.dart",
            float(os.getenv("QUALITY_MIN_AUTH_CONTROLLER_COVERAGE", "85")),
        ),
        (
            "lib/data/datasources/remote/auth_datasource.dart",
            float(os.getenv("QUALITY_MIN_AUTH_DATASOURCE_COVERAGE", "80")),
        ),
        (
            "lib/features/laboratorio/data/repositories/laudo_repository_impl.dart",
            float(os.getenv("QUALITY_MIN_LAUDO_REPOSITORY_COVERAGE", "85")),
        ),
        (
            "lib/features/laboratorio/presentation/providers/laudo_provider.dart",
            float(os.getenv("QUALITY_MIN_LAUDO_PROVIDER_COVERAGE", "50")),
        ),
        (
            "lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart",
            float(os.getenv("QUALITY_MIN_RECOMENDACAO_SCREEN_COVERAGE", "70")),
        ),
        (
            "lib/domain/usecases/recomendacao_engine.dart",
            float(os.getenv("QUALITY_MIN_RECOMENDACAO_ENGINE_COVERAGE", "70")),
        ),
        (
            "lib/features/historico/presentation/historico_page.dart",
            float(os.getenv("QUALITY_MIN_HISTORICO_PAGE_COVERAGE", "80")),
        ),
    ]

    min_critical_aggregate = float(os.getenv("QUALITY_MIN_CRITICAL_COVERAGE", "70"))
    min_global_cov_raw = os.getenv("QUALITY_MIN_GLOBAL_COVERAGE", "").strip()
    min_global_cov = float(min_global_cov_raw) if min_global_cov_raw else None

    print("[COVERAGE] Evaluating critical thresholds...")

    missing = []
    failed = []
    total_lf = 0
    total_lh = 0

    for path, min_cov in critical_files:
        if path not in records:
            missing.append(path)
            continue
        lf, lh = records[path]
        cov = _pct(lf, lh)
        total_lf += lf
        total_lh += lh
        status = "OK" if cov >= min_cov else "FAIL"
        print(
            f"  - {path}: {cov:.2f}% (LH={lh}, LF={lf}) "
            f"[min={min_cov:.2f}%] -> {status}"
        )
        if cov < min_cov:
            failed.append((path, cov, min_cov))

    if missing:
        print("[COVERAGE][FAIL] Missing critical files in LCOV:")
        for item in missing:
            print(f"  - {item}")
        return 1

    agg_cov = _pct(total_lf, total_lh)
    agg_status = "OK" if agg_cov >= min_critical_aggregate else "FAIL"
    print(
        f"[COVERAGE] Critical aggregate: {agg_cov:.2f}% "
        f"(LH={total_lh}, LF={total_lf}) "
        f"[min={min_critical_aggregate:.2f}%] -> {agg_status}"
    )

    if min_global_cov is not None:
        g_lf = sum(v[0] for v in records.values())
        g_lh = sum(v[1] for v in records.values())
        g_cov = _pct(g_lf, g_lh)
        g_status = "OK" if g_cov >= min_global_cov else "FAIL"
        print(
            f"[COVERAGE] Global aggregate: {g_cov:.2f}% "
            f"(LH={g_lh}, LF={g_lf}) "
            f"[min={min_global_cov:.2f}%] -> {g_status}"
        )
        if g_cov < min_global_cov:
            failed.append(("GLOBAL", g_cov, min_global_cov))

    if agg_cov < min_critical_aggregate:
        failed.append(("CRITICAL_AGGREGATE", agg_cov, min_critical_aggregate))

    if failed:
        print("[COVERAGE][FAIL] Threshold violations:")
        for item, actual, min_cov in failed:
            print(f"  - {item}: actual={actual:.2f}% < min={min_cov:.2f}%")
        return 1

    print("[COVERAGE] All thresholds satisfied.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
