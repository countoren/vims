{ vimUtils, fetchFromGitHub }:
{
  ultisnips = vimUtils.buildVimPluginFrom2Nix {
    name = "ultisnips-countoren-2019-07-08";
    src = fetchFromGitHub {
      owner = "countoren";
      repo = "ultisnips";
      rev = "86c7a7f";
      sha256 = "16a6ahgssbdras8hd7c2i5ncc17ngzlw8695cq7sw1k88wwks6fg";
    };
    dependencies = [];
  };

  ale = vimUtils.buildVimPluginFrom2Nix {
    name = "ale-2017-07-10";
    src = fetchFromGitHub {
      owner = "w0rp";
      repo = "ale";
      rev = "b44f6053d1faffa47191009f84dc36d14ebc3992";
      sha256 = "1vdk8s5inry8xkwa10cyjfdjqyxby76n2sm7gkz0rfqagh9v10g8";
    };
    dependencies = [];
  };


  vim-wombat = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-wombat-2017-12-22";
    src = fetchFromGitHub {
      owner = "vim-scripts";
      repo = "wombat256.vim";
      rev = "8734ba45dcf5e38c4d2686b35c94f9fcb30427e2";
      sha256 = "01fdvfwdfqn5xi88lfanb4lb6jmn1ma6wq6d9jj2x7qamdbpvsrg";
    };
    dependencies = [];
  };


  vim-javascript = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-javascript-2016-11-10";
    src = fetchFromGitHub {
      owner = "pangloss";
      repo = "vim-javascript";
      rev = "d736e95330e8aa343613ad8cddf1e7cc82de7ade";
      sha256 = "136q0ask4dp99dp7fbyi1v2qrdfy6mnrh0a3hzsy9aw5g2f2rvbj";
    };
    dependencies = [];
  };

}
