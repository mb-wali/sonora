/**
 * @author sarahr
 */

import React from "react";

import { useTranslation } from "i18n";
import ErrorIcon from "@material-ui/icons/Error";
import { build } from "@cyverse-de/ui-lib";
import {
    Card,
    CardActions,
    CardContent,
    CardHeader,
    Divider,
    Grid,
    makeStyles,
    Typography,
} from "@material-ui/core";

import ClientInfo from "../utils/error/ClientInfo";
import ContactSupport from "../utils/error/ContactSupport";
import ids from "./ids";

const useStyles = makeStyles((theme) => ({
    cardContent: {
        padding: theme.spacing(2),
        [theme.breakpoints.down("xs")]: {
            padding: theme.spacing(1),
        },
    },
    container: {
        margin: theme.spacing(1),
        [theme.breakpoints.down("xs")]: {
            margin: theme.spacing(0),
        },
    },
    signIn: {
        padding: theme.spacing(1),
    },
    link: {
        cursor: "pointer",
    },
}));

function OAuthErrorHandler(props) {
    const { errorCode, baseId } = props;
    const { t } = useTranslation("oauth");
    const errorBaseId = build(baseId, ids.OAUTH_ERROR_HANDLER);
    const classes = useStyles();

    const avatar = <ErrorIcon fontSize="large" color="error" />;
    const title = (
        <Typography color="error" variant="h6">
            {t("oops")}
        </Typography>
    );
    const subheader = <Typography color="error">{t(errorCode)}</Typography>;

    return (
        <Card id={errorBaseId}>
            <CardHeader avatar={avatar} title={title} subheader={subheader} />
            <Divider orientation="horizontal" />
            <CardContent className={classes.cardContent}>
                <Grid container spacing={2} className={classes.container}>
                    <ClientInfo baseId={errorBaseId} />
                </Grid>
            </CardContent>
            <Divider orientation="horizontal" />
            <CardActions>
                <ContactSupport baseId={errorBaseId} />
            </CardActions>
        </Card>
    );
}

export default OAuthErrorHandler;
