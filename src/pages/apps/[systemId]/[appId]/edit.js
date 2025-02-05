/**
 * A page for displaying the App or Workflow Editor for an app or pipeline
 * with the given IDs.
 *
 * @author psarando
 */
import React from "react";

import { useRouter } from "next/router";
import { useQuery } from "react-query";

import AppEditor from "components/apps/editor";
import ids from "components/apps/editor/ids";
import WorkflowEditor from "components/apps/workflows/Editor";
import WorkflowIds from "components/apps/workflows/ids";
import { signInErrorResponse } from "components/error/errorCode";

import { useUserProfile } from "contexts/userProfile";

import {
    getAppUI,
    getAppById,
    APP_UI_QUERY_KEY,
    APP_BY_ID_QUERY_KEY,
} from "serviceFacades/apps";

import { getPipelineUI, PIPELINE_UI_QUERY_KEY } from "serviceFacades/pipelines";

export default function AppEdit() {
    const [app, setApp] = React.useState(null);
    const [workflowDescription, setWorkflowDescription] = React.useState(null);
    const [appListingInfo, setAppListingInfo] = React.useState(null);
    const [loadingError, setLoadingError] = React.useState(null);

    const [userProfile] = useUserProfile();

    const router = useRouter();
    const { systemId, appId } = router.query;

    const isPublic = appListingInfo?.is_public;
    const isWorkflow = appListingInfo?.step_count > 1;

    const { isFetching: appInfoLoading } = useQuery({
        queryKey: [APP_BY_ID_QUERY_KEY, { systemId, appId }],
        queryFn: getAppById,
        config: {
            enabled: userProfile?.id && systemId && appId,
            onSuccess: (result) => {
                setAppListingInfo(result?.apps[0]);
            },
            onError: setLoadingError,
        },
    });

    const { isFetching: appUILoading } = useQuery({
        queryKey: [APP_UI_QUERY_KEY, { systemId, appId }],
        queryFn: getAppUI,
        config: {
            enabled:
                userProfile?.id &&
                systemId &&
                appId &&
                appListingInfo &&
                !isWorkflow,
            onSuccess: setApp,
            onError: setLoadingError,
        },
    });

    const { isFetching: workflowUILoading } = useQuery({
        queryKey: [PIPELINE_UI_QUERY_KEY, { appId }],
        queryFn: getPipelineUI,
        config: {
            enabled: userProfile?.id && appId && isWorkflow,
            onSuccess: setWorkflowDescription,
            onError: setLoadingError,
        },
    });

    React.useEffect(() => {
        if (userProfile?.id) {
            setLoadingError(null);
        } else {
            setLoadingError(signInErrorResponse);
        }
    }, [userProfile]);

    const loading = appInfoLoading || appUILoading || workflowUILoading;

    if (isWorkflow) {
        return (
            <WorkflowEditor
                baseId={WorkflowIds.WORKFLOW_EDITOR_FORM}
                appDescription={workflowDescription}
                loading={loading}
                loadingError={loadingError}
            />
        );
    }

    return (
        <AppEditor
            baseId={ids.APP_EDITOR_VIEW}
            appDescription={app}
            loading={loading}
            loadingError={loadingError}
            cosmeticOnly={isPublic}
        />
    );
}

AppEdit.getInitialProps = async () => ({
    namespacesRequired: [
        "app_editor",
        "app_editor_help",
        "app_param_types",
        "apps",
        "common",
        "data",
        "launch",
        "workflows",
    ],
});
