
## How does it look like ?

![(RefreshControlPullTypeInsensitive)](https://github.com/showmecode/RefreshControl/blob/master/images/RefreshControlPullTypeInsensitive.gif)
![(RefreshControlPullTypeSensitive)](https://github.com/showmecode/RefreshControl/blob/master/images/RefreshControlPullTypeSensitive.gif)
![(RefreshControlPullTypeInsensitiveLikeTwitter)](https://github.com/showmecode/RefreshControl/blob/master/images/RefreshControlPullTypeInsensitiveLikeTwitter.gif)

## How  to use ?

1. `#import "UIScrollView+RefreshControl.h"`
2. Using the control just like below methods

###  Sensitive Style

TopRefreshControl
    
```objective-c
    __weak typeof(self) weakSelf = self;
    [self.tableView addTopRefreshControlUsingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          // request for datas
    });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView topRefreshControlStopRefreshing];
        });
    }];
``` 

**Attention**  In call back block, you should reload data first, then stop TopRefreshControl, otherwise, your scroll view will not stay the position before.

BottomRefreshControl

```objective-c
    __weak typeof(self) weakSelf = self;
    [self.tableView addBottomRefreshControlUsingBlock:^{        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          // request for datas
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView bottomRefreshControlStopRefreshing];
            [weakSelf.tableView reloadData];
        });
    }];
```

### Insensitive Style

Pass refreshControlPullType `RefreshControlPullTypeInsensitive`

TopRefreshControl

```objective-c
addTopRefreshControlUsingBlock:refreshControlPullType:
```

BottomRefreshControl

```objective-c
addBottomRefreshControlUsingBlock:refreshControlPullType:
```

