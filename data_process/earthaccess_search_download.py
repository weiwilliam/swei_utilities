#!/usr/bin/env python
"""Search and download NASA Earthdata granules through the earthaccess package.

A NASA Earthdata Login credential is needed. Create a ``.netrc`` under your home
directory holding::

    machine urs.earthdata.nasa.gov login [account] password [password]

Examples
--------
List the collections matching a keyword::

    ./earthaccess_search_download.py search --keyword CALIOP

Check which granules would be pulled, without writing anything to disk::

    ./earthaccess_search_download.py download \
        --short-name CAL_LID_L2_05kmAPro-Standard-V5-00 \
        --version V5-00 --prodtype caliop_apro_v500 \
        --start 2008060300 --final 2008060318 --window 6 \
        --rawdir /glade/work/swei/data/RawOBS \
        --dry-run

Drop ``--dry-run`` to perform the download.
"""

import argparse
import os
import sys
from datetime import datetime, timedelta

import earthaccess

DATE_FMT = "%Y%m%d%H"


def get_dates(start_date, final_date, window_length):
    """Return the analysis times from ``start_date`` to ``final_date``.

    ``start_date`` and ``final_date`` are ``YYYYMMDDHH`` strings and
    ``window_length`` is the spacing between cycles, in hours. Both ends are
    included.
    """
    beg = datetime.strptime(start_date, DATE_FMT)
    end = datetime.strptime(final_date, DATE_FMT)
    if end < beg:
        raise ValueError(f"final date {final_date} precedes start date {start_date}")

    step = timedelta(hours=window_length)
    dates = []
    current = beg
    while current <= end:
        dates.append(current)
        current += step
    return dates


def drop_none(**kwargs):
    """Strip unset options out of a query.

    earthaccess turns an explicit ``None`` into a literal query parameter and
    the CMR search then quietly matches nothing, so optional arguments have to
    be left out entirely rather than passed as None.
    """
    return {key: value for key, value in kwargs.items() if value is not None}


def granule_name(granule):
    """Best-effort file name of a granule, used to spot what is already local."""
    links = granule.data_links()
    if links:
        return os.path.basename(links[0])
    return granule["meta"].get("native-id", "unknown-granule")


def granule_size(granule):
    """Granule size in MB, or 0.0 when the metadata does not carry one."""
    # earthaccess caches the size under the "size" key; reading it directly
    # avoids the deprecation warning attached to the size() method.
    try:
        return float(granule["size"])
    except (KeyError, TypeError, ValueError):
        return 0.0


def cmd_search(args):
    """Search collections by keyword and list what came back."""
    datasets = earthaccess.search_datasets(
        **drop_none(
            keyword=args.keyword,
            short_name=args.short_name,
            provider=args.provider,
            count=args.count,
        )
    )

    if not datasets:
        print("No collection matched the search.")
        return 1

    print(f"{len(datasets)} collection(s) found\n")
    print(f"{'#':>4}  {'ShortName':<48}  {'Version':<10}  Provider")
    print("-" * 100)
    for idx, dataset in enumerate(datasets, start=1):
        umm = dataset["umm"]
        provider = dataset["meta"].get("provider-id", "")
        print(
            f"{idx:>4}  {umm['ShortName']:<48}  {umm['Version']:<10}  {provider}"
        )
        if args.long:
            print(f"        title      : {umm.get('EntryTitle', '')}")
            print(f"        concept-id : {dataset['meta'].get('concept-id', '')}")

    print("\nFeed a ShortName/Version pair back in through the download command.")
    return 0


def cmd_download(args):
    """Walk the cycles and download (or, with --dry-run, only report) granules."""
    dates = get_dates(args.start, args.final, args.window)
    half_dt = timedelta(hours=args.window / 2)
    destdir = os.path.join(args.rawdir, args.prodtype)

    print(f"Product     : {args.short_name} ({args.version or 'any version'})")
    print(f"Destination : {destdir}")
    print(f"Cycles      : {len(dates)} from {args.start} to {args.final} "
          f"every {args.window} h")
    if args.dry_run:
        print("Mode        : DRY RUN, nothing will be written to disk")
    print()

    total_missing = 0
    total_size = 0.0

    for date in dates:
        cdate_str = date.strftime(DATE_FMT)
        print(f"Processing: {cdate_str}")
        cdate_dir = os.path.join(destdir, cdate_str)

        if os.path.isdir(cdate_dir):
            existing = {
                entry.name for entry in os.scandir(cdate_dir) if entry.is_file()
            }
        else:
            existing = set()

        winbeg = date - half_dt
        winend = date + half_dt
        granules = earthaccess.search_data(
            **drop_none(
                short_name=args.short_name,
                version=args.version,
                temporal=(winbeg, winend),
            )
        )

        if not granules:
            print("  No files available")
            continue

        if args.overwrite:
            wanted = list(granules)
        else:
            wanted = [g for g in granules if granule_name(g) not in existing]

        print(f"  {len(existing)} file(s) exist, {len(granules)} file(s) available, "
              f"{len(wanted)} to download")

        if not wanted:
            continue

        cycle_size = sum(granule_size(g) for g in wanted)
        total_missing += len(wanted)
        total_size += cycle_size

        if args.dry_run:
            for granule in wanted:
                print(f"    {granule_name(granule):<70} {granule_size(granule):8.1f} MB")
            continue

        os.makedirs(cdate_dir, exist_ok=True)
        earthaccess.download(wanted, cdate_dir, show_progress=args.progress)

    print()
    verb = "would be downloaded" if args.dry_run else "downloaded"
    print(f"{total_missing} file(s) {verb}, {total_size / 1024.0:.2f} GB total")
    return 0


def build_parser():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    search = subparsers.add_parser(
        "search", help="search collections by keyword and list them"
    )
    search.add_argument("-k", "--keyword", help="free-text keyword, e.g. CALIOP")
    search.add_argument("-s", "--short-name", help="restrict to a collection short name")
    search.add_argument(
        "-p", "--provider", help="restrict to a provider, e.g. OB_CLOUD for PACE"
    )
    search.add_argument(
        "-n", "--count", type=int, default=50, help="max collections to list (default 50)"
    )
    search.add_argument(
        "-l", "--long", action="store_true", help="also print title and concept-id"
    )
    search.set_defaults(func=cmd_search)

    download = subparsers.add_parser(
        "download", help="download granules cycle by cycle"
    )
    download.add_argument(
        "-s", "--short-name", required=True, help="collection short name"
    )
    download.add_argument("-v", "--version", help="collection version, e.g. V5-00")
    download.add_argument(
        "-t", "--prodtype", required=True,
        help="product tag used as the sub-directory under --rawdir",
    )
    download.add_argument(
        "--start", required=True, help="first cycle, YYYYMMDDHH"
    )
    download.add_argument(
        "--final", required=True, help="last cycle, YYYYMMDDHH"
    )
    download.add_argument(
        "-w", "--window", type=float, default=6,
        help="assimilation window length in hours (default 6)",
    )
    download.add_argument(
        "-d", "--rawdir", required=True,
        help="root path where the data are kept; files land in "
             "<rawdir>/<prodtype>/<YYYYMMDDHH>",
    )
    download.add_argument(
        "--dry-run", action="store_true",
        help="list what would be downloaded and exit without writing anything",
    )
    download.add_argument(
        "--overwrite", action="store_true",
        help="re-download granules even when a file of that name is already there",
    )
    download.add_argument(
        "--progress", action="store_true", help="show earthaccess progress bars"
    )
    download.set_defaults(func=cmd_download)

    return parser


def main():
    args = build_parser().parse_args()

    # Login via the .netrc file; a dry run still needs it to query the CMR API.
    earthaccess.login(strategy="netrc")

    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
