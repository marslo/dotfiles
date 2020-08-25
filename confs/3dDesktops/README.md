## Installation
- Open `/usr/bin/software-center`
- Search and Install **compizconfig** (`compizconfig-settings-manager`)
- Install extra package
    <pre><code>┌─ (marslo@MJ ~) ->
    └─ $ sudo apt-get install compiz-plugins-extra
    </code></pre>

## Configuration
- Open **Compizconfig**
    <pre><code>┌─ (marslo@MJ ~) ->
    └─ $ ccsm
    </code></pre>
- **General** -> **General Options** -> **Desktop Size**
    - **Horizontal Virtual Size**: `4`
    - **Vertical Virtual Size**: `1`

- **Desktop**
    - Un-select **Desktop Wall**
    - Select **Desktop Cube**
    - Select **Rotate Cube**

- **Effects**
  - Un-select **Fading Windows**
  - Select **Wobbly Windows**
  - Select **Animation**
      - **Open Animation**: `Wave`
      - **Close Animation**: `Dream`

- **Window Management**
    - Select **Shift Switch**

### Restore to the original
    ┌─ (marslo@MJ ~) ->
    └─ $ rm -rf .config/compiz* .gconf/apps/compiz*

### Inspired from [forum.ubuntu.org.cn](http://forum.ubuntu.org.cn/viewtopic.php?t=140531)
