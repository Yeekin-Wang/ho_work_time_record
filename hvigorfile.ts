import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { hvigor } from '@ohos/hvigor';

// 自定义插件：动态设置产物文件名，自动带上版本号
function dynamicArtifactNamePlugin() {
  return {
    pluginId: 'DynamicArtifactNamePlugin',
    apply: () => {
      hvigor.afterNodeEvaluate((node) => {
        const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
        if (!appContext) {
          return;
        }
        // 获取 app.json5 中的配置
        const appJson = appContext.getAppJsonOpt();
        const versionName = appJson?.app?.versionName ?? '1.0.0';

        // 获取 build-profile.json5 并修改 artifactName
        const buildProfile = appContext.getBuildProfileOpt();
        const products = buildProfile?.app?.products;
        if (products) {
          for (const product of products) {
            if (product.name === 'default') {
              if (!product.output) {
                product.output = {};
              }
              product.output.artifactName = `com.workhour.tracker-v${versionName}`;
            }
          }
          appContext.setBuildProfileOpt(buildProfile);
        }
      });
    },
  };
}

export default {
  system: appTasks,
  plugins: [dynamicArtifactNamePlugin()]
}