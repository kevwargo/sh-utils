# extract use flag
function euf(string) { return gensub(/^-+/, "", 1, string); }
# extract package name
function epn(string) { return gensub(/^[<>=]+/, "", 1, string); }
function print_uses(uses) { for (i in uses) print " " uses[i]; }
# sort and cleanse useflag string
function sort(uses_, use, a, s, l)
{
    l = split(uses_, a);
    if (use == "")
        for (i = 1; i < l; i++)
            for (j = i + 1; j <= l; j++)
            {
                if (i in a && j in a && euf(a[i]) == euf(a[j]))
                    { a[i] = a[j]; delete a[j] };
            }
    else
        for (i = 1; i <= l; i++)
            if (use ~ ("(^|\\s)" a[i] "(\\s|$)"))
                delete a[i];
    l = asort(a);
    for (i = 1; i < l; i++) s = s a[i] " ";
    s = s a[l];
    return s;
}

{
    if ($1 == prev)
        for (i = 2; i <= NF; i++)
            prev_uses = prev_uses $i " ";
    else
    {
        if (prev == pkg)
        {
            if (progname == "adduse") prev_uses = prev_uses uses;
            else if (progname == "deluse") prev_uses = sort(prev_uses, uses);
            if (prev_uses == "") prev = "";
        }
        if (NR > 1 && prev)
            print prev, sort(prev_uses);
        if (progname == "adduse" && epn(prev) < epn(pkg) && epn(pkg) < epn($1))
            print pkg, sort(uses);
        prev = $1;
        prev_uses = "";
        for (i = 2; i <= NF; i++)
            prev_uses = prev_uses $i " ";
    }
}

END {
    if (pkg == prev)
    {
        if (progname == "adduse") prev_uses = prev_uses uses;
        else if (progname == "deluse") prev_uses = sort(prev_uses, uses);
        if (prev_uses == "") prev = ""
    }
    if (prev)
        print prev, sort(prev_uses);
    if (progname == "adduse" && pkg > prev)
        print pkg, sort(uses)
}
