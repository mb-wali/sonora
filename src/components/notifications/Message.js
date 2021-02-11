/**
 * Displays a notification message with support for navigating to another page,
 * or some other action, when certain message types are clicked / tapped.
 *
 * @author psarando
 */
import React, { useState } from "react";

import Link from "next/link";

import {
    ADDED_TO_TEAM,
    getDisplayMessage,
    JOIN_TEAM_DENIED,
    REQUEST_TO_JOIN,
} from "./utils";

import NotificationCategory from "components/models/NotificationCategory";
import SystemId from "components/models/systemId";

import { getAnalysisDetailsLinkRefs } from "components/analyses/utils";
import { getAppListingLinkRefs } from "components/apps/utils";
import { getFolderPage, getParentPath } from "components/data/utils";
import DELink from "components/utils/DELink";

import { Typography } from "@material-ui/core";
import { getTeamLinkRefs } from "../teams/util";
import AdminJoinTeamRequestDialog from "./dialogs/AdminJoinTeamRequestDialog";
import JoinTeamDeniedDialog from "./dialogs/JoinTeamDeniedDialog";
import ExternalLink from "../utils/ExternalLink";
import { useTranslation } from "../../i18n";

function MessageLink(props) {
    const { message, href, as } = props;

    return (
        <Link href={href} as={as} passHref>
            <DELink text={message} />
        </Link>
    );
}

function AnalysisLink(props) {
    const { notification } = props;
    const { t } = useTranslation("common");

    const message = getDisplayMessage(notification);
    const action = notification.payload?.action;

    const isJobStatusChange = action === "job_status_change";
    const isShare = action === "share";
    if (isShare || isJobStatusChange) {
        if (notification.payload.access_url) {
            return (
                <ExternalLink href={props.notification.payload.access_url}>
                    {t("interactiveAnalysisUrl", { message })}
                </ExternalLink>
            );
        }

        const analysisId =
            isShare && notification.payload?.analyses?.length > 0
                ? notification.payload.analyses[0].analysis_id
                : isJobStatusChange && notification.payload?.id;

        if (analysisId) {
            const [href, as] = getAnalysisDetailsLinkRefs(analysisId);

            return <MessageLink message={message} href={href} as={as} />;
        }
    }

    return message;
}

function AppLink(props) {
    const { notification } = props;

    const message = getDisplayMessage(notification);
    const action = notification.payload?.action;

    if (action === "share" && notification.payload?.apps?.length > 0) {
        const app = notification.payload.apps[0];

        const [href, as] = getAppListingLinkRefs(
            app.system_id || SystemId.de,
            app.app_id
        );

        return <MessageLink message={message} href={href} as={as} />;
    }

    return message;
}

function DataLink(props) {
    const { notification } = props;

    const message = getDisplayMessage(notification);
    const action = notification.payload?.action;

    const rootFolderAction = action === "delete" || action === "empty_trash";

    // payload.paths is present for most actions,
    // but `file_uploaded` and `UPLOAD_COMPLETE` actions will have
    // payload.data.path
    const path =
        notification.payload?.paths?.length > 0
            ? notification.payload?.paths[0]
            : notification.payload?.data?.path;

    const href =
        path && getFolderPage(rootFolderAction ? path : getParentPath(path));

    return href ? <MessageLink href={href} message={message} /> : message;
}

function TeamLink(props) {
    const { notification } = props;

    const message = getDisplayMessage(notification);
    const teamName = notification.payload?.team_name;
    const action = notification.payload?.action;

    const [adminJoinRequestDlgOpen, setAdminJoinRequestDlgOpen] = useState(
        false
    );
    const [joinRequestDeniedDlgOpen, setJoinRequestDeniedDlgOpen] = useState(
        false
    );

    if (action === ADDED_TO_TEAM) {
        const [href] = getTeamLinkRefs(teamName);
        return <MessageLink href={href} message={message} />;
    }

    if (action === REQUEST_TO_JOIN) {
        return (
            <>
                <DELink
                    onClick={(event) => {
                        event.stopPropagation();
                        setAdminJoinRequestDlgOpen(true);
                    }}
                    text={message}
                />
                <AdminJoinTeamRequestDialog
                    open={adminJoinRequestDlgOpen}
                    onClose={() => setAdminJoinRequestDlgOpen(false)}
                    request={notification.payload}
                />
            </>
        );
    }

    if (action === JOIN_TEAM_DENIED) {
        return (
            <>
                <DELink
                    onClick={(event) => {
                        event.stopPropagation();
                        setJoinRequestDeniedDlgOpen(true);
                    }}
                    text={message}
                />
                <JoinTeamDeniedDialog
                    open={joinRequestDeniedDlgOpen}
                    onClose={() => setJoinRequestDeniedDlgOpen(false)}
                    adminMessage={notification?.payload?.admin_message}
                    teamName={notification?.payload?.team_name}
                />
            </>
        );
    }

    return message;
}

export default function Message(props) {
    const { baseId, notification } = props;

    let message;

    switch (notification.type.toLowerCase()) {
        case NotificationCategory.ANALYSIS.toLowerCase():
            message = <AnalysisLink notification={notification} />;

            break;

        case NotificationCategory.APPS.toLowerCase():
            message = <AppLink notification={notification} />;

            break;

        case NotificationCategory.DATA.toLowerCase():
            message = <DataLink notification={notification} />;

            break;

        case NotificationCategory.TEAM.toLowerCase():
            message = <TeamLink notification={notification} />;

            break;

        default:
            message = getDisplayMessage(notification);
            break;
    }

    return (
        <Typography id={baseId} variant="subtitle2">
            {message}
        </Typography>
    );
}
