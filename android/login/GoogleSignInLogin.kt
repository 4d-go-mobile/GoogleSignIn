package ___PACKAGE___

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.databinding.DataBindingUtil
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes
import com.google.android.gms.common.SignInButton
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Status
import com.google.android.gms.tasks.Task
import com.qmobile.qmobiledatasync.app.BaseApp
import com.qmobile.qmobiledatasync.toast.ToastMessage
import com.qmobile.qmobiledatasync.utils.LoginForm
import com.qmobile.qmobiledatasync.utils.LoginHandler
import com.qmobile.qmobileui.activity.loginactivity.LoginActivity
import com.qmobile.qmobileui.binding.bindImageFromDrawable
import com.qmobile.qmobileui.ui.SnackbarHelper
import com.qmobile.qmobileui.ui.setOnSingleClickListener
import com.qmobile.qmobileui.ui.setOnVeryLongClickListener
import ___APP_PACKAGE___.R
import ___APP_PACKAGE___.databinding.GoogleSignInLoginBinding
import timber.log.Timber

@LoginForm
class GoogleSignInLogin(private val activity: LoginActivity) : LoginHandler {

    private var _binding: GoogleSignInLoginBinding? = null
    private val binding get() = _binding!!

    override val ensureValidMail = true
    private var mGoogleSignInClient: GoogleSignInClient
    private val signInLauncher: ActivityResultLauncher<Intent> = registerSignInLauncher()

    init {
        _binding =
            DataBindingUtil.setContentView<GoogleSignInLoginBinding?>(activity, R.layout.google_sign_in_login).apply {
                lifecycleOwner = activity
            }

        val gso: GoogleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()

        mGoogleSignInClient = GoogleSignIn.getClient(activity, gso)
    }

    override fun initLayout() {
        bindImageFromDrawable(binding.loginLogo, BaseApp.loginLogoDrawable)

        binding.loginLogo.setOnVeryLongClickListener {
            activity.showRemoteUrlDialog()
        }

        binding.signInButton.setSize(SignInButton.SIZE_WIDE)
        binding.signInButton.setOnSingleClickListener {
            signIn()
        }
    }
     
    override fun validate(input: String): Boolean {
        return true
    }

    override fun onInputInvalid() {
        // Nothing to do
    }

    override fun onLoginInProgress(inProgress: Boolean) {
        binding.signInButton.visibility = if (inProgress) View.GONE else View.VISIBLE
        binding.loginProgressbar.visibility = if (inProgress) View.VISIBLE else View.GONE
    }

    override fun onLoginSuccessful() {
        // Nothing to do
    }

    override fun onLoginUnsuccessful() {
        // Nothing to do
    }

    override fun onLogout() {
        SnackbarHelper.show(activity, activity.resources.getString(R.string.login_google_signing_out))
        binding.signInButton.visibility = View.GONE
        binding.loginProgressbar.visibility = View.VISIBLE
        mGoogleSignInClient.signOut().addOnCompleteListener {
            SnackbarHelper.show(activity, activity.resources.getString(R.string.login_google_signed_out))
            binding.signInButton.visibility = View.VISIBLE
            binding.loginProgressbar.visibility = View.GONE
        }
    }

    private fun signIn() {
        val signInIntent: Intent = mGoogleSignInClient.signInIntent
        signInLauncher.launch(signInIntent)
    }

    private fun registerSignInLauncher(): ActivityResultLauncher<Intent> {
        return activity.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
            if (activityResult.resultCode == Activity.RESULT_OK) {
                // The Task returned from this call is always completed, no need to attach a listener.
                val task = GoogleSignIn.getSignedInAccountFromIntent(activityResult.data)
                handleSignInResult(task)
            } else {
                (activityResult.data?.extras?.get("googleSignInStatus") as Status?)?.statusCode?.let {
                    handleError(it, false)
                }
            }
        }
    }

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            completedTask.getResult(ApiException::class.java).email?.let {
                activity.login(it)
            } ?: kotlin.run {
                SnackbarHelper.show(
                    activity,
                    "No email attached to this account",
                    ToastMessage.Type.WARNING
                )
            }
        } catch (e: ApiException) {
            handleError(e.statusCode, true)
        }
    }

    private fun handleError(statusCode: Int, showError: Boolean) {
        Timber.e("status code: $statusCode")
        val statusCodeString = GoogleSignInStatusCodes.getStatusCodeString(statusCode)
        Timber.e("statusCodeString: $statusCodeString")
        if (showError) {
            SnackbarHelper.show(activity, statusCodeString, ToastMessage.Type.WARNING)
        }
    }
}
