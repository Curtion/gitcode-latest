package gitcodeLatest

import std.os.{currentDir, getArgs, process}
import std.fs.{Directory, Path}
import std.io.{ByteArrayStream, StringReader}
import std.collection.ArrayList

main() {
    var path: Directory
    var branch: String
    let args = getArgs()
    if(args.size >= 1) {
        path = Directory(args[0])
    } else {
        path = currentDir()
    }
    if (args.size >= 2) {
        branch = args[1]
    } else {
        branch = "master"
    }
    let dirs = path.directoryList()
    let futs = ArrayList<Future<Unit>>(3)
    for(item in dirs) {
        if(item.isDirectory()) {
            if(isBranch(item.path, branch) && isUnchanged(item.path)) {
                let fut: Future<Unit> = spawn {
                    gitPull(item.path)
                }
                futs.append(fut)
            } else {
                println("${item.path.fileName}: 仓库当前分支不正确, 或者有未提交的代码,无法更新~!")
            }
        }
    }
    for(fut in futs) {
        fut.get()
    }
    println("更新完成~!")
}

func isBranch(path: Path, branch: String): Bool {
    let p = process.Process.runOutput("git", ["branch", "--show-current"], workingDirectory:Some(path))
    let str = String.fromUtf8(p[1])
    return str.trimAscii() == branch
}

func isUnchanged(path: Path): Bool {
    let p = process.Process.runOutput("git", ["diff", "--exit-code"], workingDirectory:Some(path))
    return p[0] == 0
}

func gitPull(path: Path) {
    process.Process.runOutput("git", ["pull"], workingDirectory:Some(path))
}