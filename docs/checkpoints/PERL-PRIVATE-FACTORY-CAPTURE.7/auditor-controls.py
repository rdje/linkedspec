            altered += tuple(current.replace(insertion, b"", 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            altered += tuple(current.replace(insertion, insertion * 2, 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            for path in PRIVATE_FACTORY_FIXTURE_PATHS:
                line = b" " + path.encode() + b"\n"
                require(current.count(line) == 1, "private fixture path is not unique")
                altered += (current.replace(line, b"", 1),
                            current.replace(line, line * 2, 1))
            altered += (
                current.replace(b'PERL5OPT= prove -Iperl "${private_factory_suites[@]}"',
                                b'PERL5OPT= true "${private_factory_suites[@]}"', 1),
                current.replace(b' perl -c -Iperl "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b' require_tracked_file "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b" t/actionir_default_object_capture.t\n",
                                b" t/other_private_fixture.t\n", 1),
            )
