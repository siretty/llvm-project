#!/usr/bin/env python

"""
CmpRuns - A simple tool for comparing two static analyzer runs to determine
which reports have been added, removed, or changed.

This is designed to support automated testing using the static analyzer, from
two perspectives:
  1. To monitor changes in the static analyzer's reports on real code bases,
     for regression testing.

  2. For use by end users who want to integrate regular static analyzer testing
     into a buildbot like environment.

Usage:

    # Load the results of both runs, to obtain lists of the corresponding
    # AnalysisDiagnostic objects.
    #
    resultsA = loadResultsFromSingleRun(singleRunInfoA, deleteEmpty)
    resultsB = loadResultsFromSingleRun(singleRunInfoB, deleteEmpty)

    # Generate a relation from diagnostics in run A to diagnostics in run B
    # to obtain a list of triples (a, b, confidence).
    diff = compareResults(resultsA, resultsB)

"""

import os
import plistlib
from math import log
from optparse import OptionParser


# Information about analysis run:
# path - the analysis output directory
# root - the name of the root directory, which will be disregarded when
# determining the source file name
class SingleRunInfo:
    def __init__(self, path, root="", verboseLog=None):
        self.path = path
        self.root = root.rstrip("/\\")
        self.verboseLog = verboseLog


class AnalysisDiagnostic:
    def __init__(self, data, report, htmlReport):
        self._data = data
        self._loc = self._data['location']
        self._report = report
        self._htmlReport = htmlReport
        self._reportSize = len(self._data['path'])

    def getFileName(self):
        root = self._report.run.root
        fileName = self._report.files[self._loc['file']]
        if fileName.startswith(root) and len(root) > 0:
            return fileName[len(root) + 1:]
        return fileName

    def getLine(self):
        return self._loc['line']

    def getColumn(self):
        return self._loc['col']

    def getPathLength(self):
        return self._reportSize

    def getCategory(self):
        return self._data['category']

    def getDescription(self):
        return self._data['description']

    def getIssueIdentifier(self):
        id = self.getFileName() + "+"
        if 'issue_context' in self._data:
            id += self._data['issue_context'] + "+"
        if 'issue_hash_content_of_line_in_context' in self._data:
            id += str(self._data['issue_hash_content_of_line_in_context'])
        return id

    def getReport(self):
        if self._htmlReport is None:
            return " "
        return os.path.join(self._report.run.path, self._htmlReport)

    def getReadableName(self):
        if 'issue_context' in self._data:
            funcnamePostfix = "#" + self._data['issue_context']
        else:
            funcnamePostfix = ""
        return '%s%s:%d:%d, %s: %s' % (self.getFileName(),
                                       funcnamePostfix,
                                       self.getLine(),
                                       self.getColumn(), self.getCategory(),
                                       self.getDescription())

    # Note, the data format is not an API and may change from one analyzer
    # version to another.
    def getRawData(self):
        return self._data


class AnalysisReport:
    def __init__(self, run, files):
        self.run = run
        self.files = files
        self.diagnostics = []


class AnalysisRun:
    def __init__(self, info):
        self.path = info.path
        self.root = info.root
        self.info = info
        self.reports = []
        # Cumulative list of all diagnostics from all the reports.
        self.diagnostics = []
        self.clang_version = None

    def getClangVersion(self):
        return self.clang_version

    def readSingleFile(self, p, deleteEmpty):
        data = plistlib.readPlist(p)

        # We want to retrieve the clang version even if there are no
        # reports. Assume that all reports were created using the same
        # clang version (this is always true and is more efficient).
        if 'clang_version' in data:
            if self.clang_version is None:
                self.clang_version = data.pop('clang_version')
            else:
                data.pop('clang_version')

        # Ignore/delete empty reports.
        if not data['files']:
            if deleteEmpty:
                os.remove(p)
            return

        # Extract the HTML reports, if they exists.
        if 'HTMLDiagnostics_files' in data['diagnostics'][0]:
            htmlFiles = []
            for d in data['diagnostics']:
                # FIXME: Why is this named files, when does it have multiple
                # files?
                assert len(d['HTMLDiagnostics_files']) == 1
                htmlFiles.append(d.pop('HTMLDiagnostics_files')[0])
        else:
            htmlFiles = [None] * len(data['diagnostics'])

        report = AnalysisReport(self, data.pop('files'))
        diagnostics = [AnalysisDiagnostic(d, report, h)
                       for d, h in zip(data.pop('diagnostics'), htmlFiles)]

        assert not data

        report.diagnostics.extend(diagnostics)
        self.reports.append(report)
        self.diagnostics.extend(diagnostics)


def loadResults(path, opts, root="", deleteEmpty=True):
    """
    Backwards compatibility API.
    """
    return loadResultsFromSingleRun(SingleRunInfo(path, root, opts.verboseLog),
                                    deleteEmpty)


def loadResultsFromSingleRun(info, deleteEmpty=True):
    """
    # Load results of the analyzes from a given output folder.
    # - info is the SingleRunInfo object
    # - deleteEmpty specifies if the empty plist files should be deleted

    """
    path = info.path
    run = AnalysisRun(info)

    if os.path.isfile(path):
        run.readSingleFile(path, deleteEmpty)
    else:
        for (dirpath, dirnames, filenames) in os.walk(path):
            for f in filenames:
                if (not f.endswith('plist')):
                    continue
                p = os.path.join(dirpath, f)
                run.readSingleFile(p, deleteEmpty)

    return run


def cmpAnalysisDiagnostic(d):
    return d.getIssueIdentifier()


def compareResults(A, B, opts):
    """
    compareResults - Generate a relation from diagnostics in run A to
    diagnostics in run B.

    The result is the relation as a list of triples (a, b) where
    each element {a,b} is None or a matching element from the respective run
    """

    res = []

    # Map size_before -> size_after
    path_difference_data = []

    # Quickly eliminate equal elements.
    neqA = []
    neqB = []
    eltsA = list(A.diagnostics)
    eltsB = list(B.diagnostics)
    eltsA.sort(key=cmpAnalysisDiagnostic)
    eltsB.sort(key=cmpAnalysisDiagnostic)
    while eltsA and eltsB:
        a = eltsA.pop()
        b = eltsB.pop()
        if (a.getIssueIdentifier() == b.getIssueIdentifier()):
            if a.getPathLength() != b.getPathLength():
                if opts.relative_path_histogram:
                    path_difference_data.append(
                        float(a.getPathLength()) / b.getPathLength())
                elif opts.relative_log_path_histogram:
                    path_difference_data.append(
                        log(float(a.getPathLength()) / b.getPathLength()))
                elif opts.absolute_path_histogram:
                    path_difference_data.append(
                        a.getPathLength() - b.getPathLength())

            res.append((a, b))
        elif a.getIssueIdentifier() > b.getIssueIdentifier():
            eltsB.append(b)
            neqA.append(a)
        else:
            eltsA.append(a)
            neqB.append(b)
    neqA.extend(eltsA)
    neqB.extend(eltsB)

    # FIXME: Add fuzzy matching. One simple and possible effective idea would
    # be to bin the diagnostics, print them in a normalized form (based solely
    # on the structure of the diagnostic), compute the diff, then use that as
    # the basis for matching. This has the nice property that we don't depend
    # in any way on the diagnostic format.

    for a in neqA:
        res.append((a, None))
    for b in neqB:
        res.append((None, b))

    if opts.relative_log_path_histogram or opts.relative_path_histogram or \
            opts.absolute_path_histogram:
        from matplotlib import pyplot
        pyplot.hist(path_difference_data, bins=100)
        pyplot.show()

    return res


def dumpScanBuildResultsDiff(dirA, dirB, opts, deleteEmpty=True):
    # Load the run results.
    resultsA = loadResults(dirA, opts, opts.rootA, deleteEmpty)
    resultsB = loadResults(dirB, opts, opts.rootB, deleteEmpty)

    # Open the verbose log, if given.
    if opts.verboseLog:
        auxLog = open(opts.verboseLog, "wb")
    else:
        auxLog = None

    diff = compareResults(resultsA, resultsB, opts)
    foundDiffs = 0
    totalAdded = 0
    totalRemoved = 0
    for res in diff:
        a, b = res
        if a is None:
            print "ADDED: %r" % b.getReadableName()
            foundDiffs += 1
            totalAdded += 1
            if auxLog:
                print >>auxLog, ("('ADDED', %r, %r)" % (b.getReadableName(),
                                                        b.getReport()))
        elif b is None:
            print "REMOVED: %r" % a.getReadableName()
            foundDiffs += 1
            totalRemoved += 1
            if auxLog:
                print >>auxLog, ("('REMOVED', %r, %r)" % (a.getReadableName(),
                                                          a.getReport()))
        else:
            pass

    TotalReports = len(resultsB.diagnostics)
    print "TOTAL REPORTS: %r" % TotalReports
    print "TOTAL DIFFERENCES: %r" % foundDiffs
    print "TOTAL ADDED: %r" % totalAdded
    print "TOTAL REMOVED: %r" % totalRemoved
    if auxLog:
        print >>auxLog, "('TOTAL NEW REPORTS', %r)" % TotalReports
        print >>auxLog, "('TOTAL DIFFERENCES', %r)" % foundDiffs

    return foundDiffs, len(resultsA.diagnostics), len(resultsB.diagnostics)

def generate_option_parser():
    parser = OptionParser("usage: %prog [options] [dir A] [dir B]")
    parser.add_option("", "--rootA", dest="rootA",
                      help="Prefix to ignore on source files for directory A",
                      action="store", type=str, default="")
    parser.add_option("", "--rootB", dest="rootB",
                      help="Prefix to ignore on source files for directory B",
                      action="store", type=str, default="")
    parser.add_option("", "--verbose-log", dest="verboseLog",
                      help="Write additional information to LOG \
                           [default=None]",
                      action="store", type=str, default=None,
                      metavar="LOG")
    parser.add_option("--relative-path-differences-histogram",
                      action="store_true", dest="relative_path_histogram",
                      default=False,
                      help="Show histogram of relative paths differences. \
                            Requires matplotlib")
    parser.add_option("--relative-log-path-differences-histogram",
                      action="store_true", dest="relative_log_path_histogram",
                      default=False,
                      help="Show histogram of log relative paths differences. \
                            Requires matplotlib")
    parser.add_option("--absolute-path-differences-histogram",
                      action="store_true", dest="absolute_path_histogram",
                      default=False,
                      help="Show histogram of absolute paths differences. \
                            Requires matplotlib")
    return parser


def main():
    parser = generate_option_parser()
    (opts, args) = parser.parse_args()

    if len(args) != 2:
        parser.error("invalid number of arguments")

    dirA, dirB = args

    dumpScanBuildResultsDiff(dirA, dirB, opts)


if __name__ == '__main__':
    main()
