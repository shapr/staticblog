{s}: 
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:staticblog' --allow-eval --warnings";
  testScript = s "test" "cabal run test:staticblog-tests";
  hoogleScript = s "hgl" "hoogle serve";
}
